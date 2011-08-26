class ApiV1::APIController < ApplicationController
  include Oauth::Controllers::ApplicationControllerMethods
  Oauth2Token = ::Oauth2Token

  skip_before_filter :rss_token, :recent_projects, :touch_user, :verify_authenticity_token, :add_chrome_frame_header
  before_filter      :api_throttle

  if Rails.env.test?
    API_LIMIT = 10
  else
    API_LIMIT = 20
  end
  API_THROTTLE_LIMIT = 200
  API_VERSION = '1.0'

  protected

  rescue_from CanCan::AccessDenied do |exception|
    api_error(:unauthorized, :type => 'InsufficientPermissions', :message => 'Insufficient permissions')
  end

  def current_user
    @current_user ||= (login_from_session ||
                       login_from_basic_auth ||
                       login_from_cookie ||
                       login_from_oauth) unless @current_user == false
  end

  def api_throttle
    return unless Rails.env.production?
    # Limit of API_THROTTLE_LIMIT per hour
    throttle_key = "#{current_user.id}:#{Time.now.strftime('%Y-%m-%dT%H')}"
    if val = Rails.cache.read(throttle_key)
      if val.to_i > API_THROTTLE_LIMIT
        api_error(:unauthorized, :type => 'AuthorizationFailed', :message => 'Rate Limit Exceeded')
      else
        Rails.cache.increment(throttle_key)
      end
    else
      Rails.cache.write(throttle_key, 1, :raw => true) # raw is needed to have 'increment' working
    end
  end

  def login_from_oauth
    user = Authenticator.new(self,[:token]).allow? ? current_token.user : nil
    user.current_token = current_token if user
    user
  end
  
  def access_denied
    api_error(:unauthorized, :type => 'AuthorizationFailed', :message => @access_denied_message || 'Login required')
  end
  
  def invalid_oauth_response(code=401,message="Invalid OAuth Request")
    @access_denied_message = message
    false
  end
  
  def load_project
    project_id ||= params[:project_id]
    
    if project_id
      @current_project = Project.find_by_id_or_permalink(project_id)
      api_error :not_found, :type => 'ObjectNotFound', :message => 'Project not found' unless @current_project
    end
  end
  
  def load_organization
    organization_id ||= params[:organization_id]
    
    if organization_id
      @organization = Organization.find_by_id_or_permalink(organization_id)
      api_error :not_found, :type => 'ObjectNotFound', :message => 'Organization not found' unless @organization
    end
  end
  
  def belongs_to_project?
    if @current_project
      unless Person.exists?(:project_id => @current_project.id, :user_id => current_user.id)
        api_error(:forbidden, :type => 'InsufficientPermissions', :message => t('common.not_allowed'))
      end
    end
  end
  
  def load_task_list
    if params[:task_list_id]
      @task_list = if @current_project
        @current_project.task_lists.find(params[:task_list_id])
      else
        TaskList.find_by_id(params[:task_list_id], :conditions => {:project_id => current_user.project_ids})
      end
      api_error :not_found, :type => 'ObjectNotFound', :message => 'TaskList not found' unless @task_list
    end
  end
  
  def load_page
    if params[:page_id]
      @page = if @current_project
        @current_project.pages.find(params[:page_id])
      else
        Page.find_by_id(params[:page_id], :conditions => {:project_id => current_user.project_ids})
      end
      api_error :not_found, :type => 'ObjectNotFound', :message => 'Page not found' unless @page
    end
  end

  # Common api helpers
  
  def api_respond(object, options={})
    content = {:json => api_wrap(object, options).to_json}
    content[:callback] = params[:callback] if request.format.js?
    response.headers['X-Tbox-Version'] = API_VERSION

    respond_to do |f|
      f.any(:json, :js, :text) { render content }
    end
  end
  
  def api_status(status)
    content = {:json => {:status => status}.to_json, :status => status}
    content[:callback] = params[:callback] if request.format.js?
    response.headers['X-Tbox-Version'] = API_VERSION

    respond_to do |f|
      f.any(:json, :js, :text) { render content }
    end
  end
  
  def api_wrap(object, options={})
    references = if options[:references] == true
      objects_references = object.respond_to?(:collect) ? object.collect(&:references) : [object.references]
      refs = objects_references.inject({}) do |m,e|
        e.each { |k,v| m[k] = (Array(m[k]) + v).compact.uniq }
        m
      end
      load_references(refs).compact.collect { |o| o.to_api_hash(options.merge(:emit_type => true)) }
    elsif options[:references] # TODO: kill. only used in search
      Array(object).map do |obj|
        options[:references].map{|ref| obj.respond_to?(ref) ? obj.send(ref) : nil }.flatten.compact
      end.flatten.uniq.map{|o| o.to_api_hash(options.merge(:emit_type => true))}
    else
      nil
    end
    
    {}.tap do |api_response|
      if object.respond_to? :each
        api_response[:type] = 'List'
        api_response[:offset] = object.offset if object.respond_to?(:offset) && object.respond_to?(:total_pages)
        api_response[:total_pages] = object.total_pages if object.respond_to?(:total_pages)
        api_response[:total_entries] = object.total_entries if object.respond_to?(:total_entries)
        api_response[:per_page] = object.per_page if object.respond_to?(:per_page)
        api_response[:current_page] = object.current_page if object.respond_to?(:current_page)
        api_response[:objects] = object.map{|o| o.to_api_hash(options.merge(:emit_type => true)) }
      else
        api_response.merge!(object.to_api_hash(options.merge(:emit_type => true)))
      end
      
      api_response[:references] = references if references
    end
  end
  
  def load_reference_hashes(refs, user_ids, people_ids)
    result = []
    
    result += refs.collect do |ref, values|
      ref_class = ref.to_s.classify
      case ref_class
      when 'Person'
        people_ids += values
        Person.where(:id => people_ids).all
      when 'Comment'
        comments = Comment.where(:id => values).includes(:target).all
        new_refs = comments.map{|c| load_reference_hashes(c.references, user_ids, people_ids)}.flatten
        comments + new_refs
      when 'Upload'
        Upload.where(:id => values).includes(:page_slot).all
      when 'GoogleDoc'
        GoogleDoc.where(:id => values).all
      when 'Note'
        Note.where(:id => values).includes(:page_slot).all
      when 'Conversation'
        convs = Conversation.where(:id => values).includes(:first_comment).includes(:recent_comments).includes(:watchers).all
        convs + convs.collect(&:first_comment) + convs.collect(&:recent_comments)
      when 'Task'
        tasks = Task.where(:id => values).includes(:first_comment).includes(:recent_comments).includes(:watchers).all
        tasks + tasks.collect(&:first_comment) + tasks.collect(&:recent_comments)
      when 'TaskListTask' # light task
        tasks = Task.where(:id => values).includes(:first_comment).includes(:recent_comments).includes(:watchers).all
        tasks + tasks.map{|t| load_reference_hashes(t.task_list_references, user_ids, people_ids)}.flatten
      else
        ref_class.constantize.where(:id => values).all
      end
    end
    
    result.flatten.uniq
  end

  # refs is a hash like: table => ids to load, e.g. { :comments => [1,2,3] }
  def load_references(refs)
    # Now let's load everything else but the users
    user_ids = Array(refs.delete(:users))
    people_ids = Array(refs.delete(:people))
    
    elements = load_reference_hashes(refs, user_ids, people_ids)

    # Load all people
    people = Person.where(:id => people_ids.uniq).all
    
    # Finally load the users we referenced before plus the ones associated to elements previously loaded
    user_ids = user_ids + (people + elements).collect { |e| e.respond_to? :user_id and e.user_id }.compact
    users = User.where(:id => user_ids.uniq).all

    # elements contains everything but users
    elements + users + people
  end

  def api_error(status_code, opts={})
    errors = {}
    errors[:type] = opts[:type] if opts[:type]
    errors[:message] = opts[:message] if opts[:message]
    content = {:json => {:errors => errors}.to_json, :status => status_code}
    content[:callback] = params[:callback] if request.format.js?
    response.headers['X-Tbox-Version'] = API_VERSION

    respond_to do |f|
      f.any(:json, :js, :text) { render content }
    end
  end
  
  def handle_api_error(object,options={})
    errors = (object.try(:errors)||{}).to_hash
    errors[:type] = 'InvalidRecord'
    errors[:message] = 'One or more fields were invalid'
    content = {:json => {:errors => errors}.to_json, :status => options.delete(:status) || :unprocessable_entity}
    content[:callback] = params[:callback] if request.format.js?
    response.headers['X-Tbox-Version'] = API_VERSION

    respond_to do |f|
      f.any(:json, :js, :text) { render content }
    end
  end
  
  def handle_api_success(object,options={})
    is_new = options.delete(:is_new)
    status = options.delete(:status) || is_new ? :created : :ok
    response.headers['X-Tbox-Version'] = API_VERSION
    
    respond_to do |f|
      if is_new || options.delete(:wrap_objects)
        content = {:json => api_wrap(object, options).to_json, :status => status}
        content[:callback] = params[:callback] if request.format.js?

        f.any(:json, :js, :text) { render content }
      else
        f.json { head(status) }
        f.js   { render :json => {:status => status}.to_json, :callback => params[:callback] }
        f.text { head(status) }
      end
    end
  end
  
  def api_truth(value)
    ['true', '1'].include?(value) ? true : false
  end

  def api_limit(options = {})
    count = params[:count] && params[:count].to_i
    return [count && count > 0 ? count : API_LIMIT, API_LIMIT].min if options[:hard]
    if count
      count == 0 ? nil : count
    else
      API_LIMIT
    end
  end

  def api_range(table_name)
    since_id = params[:since_id]
    max_id = params[:max_id]
    
    if since_id and max_id
      ["#{table_name}.id > ? AND #{table_name}.id < ?", since_id, max_id]
    elsif since_id
      ["#{table_name}.id > ?", since_id]
    elsif max_id
      ["#{table_name}.id < ?", max_id]
    else
      []
    end
  end
  
  def set_client
    request.format = :json unless request.format == :js || params[:format]
  end
  
end
