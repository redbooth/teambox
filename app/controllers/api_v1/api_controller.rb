class ApiV1::APIController < ApplicationController
  skip_before_filter :rss_token, :recent_projects, :touch_user, :verify_authenticity_token

  API_LIMIT = 50

  protected
  
  rescue_from CanCan::AccessDenied do |exception|
    api_status(:unauthorized)
  end
  
  def load_project
    project_id ||= params[:project_id]
    
    if project_id
      @current_project = Project.find_by_id_or_permalink(project_id)
      api_status(:not_found) unless @current_project
    end
  end
  
  def load_organization
    organization_id ||= params[:organization_id]
    
    if organization_id
      @organization = Organization.find_by_id_or_permalink(organization_id)
      api_status(:not_found) unless @organization
    end
  end
  
  def belongs_to_project?
    if @current_project
      unless Person.exists?(:project_id => @current_project.id, :user_id => current_user.id)
        api_error(t('common.not_allowed'), :unauthorized)
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
      api_status(:not_found) unless @task_list
    end
  end
  
  def load_page
    if params[:page_id]
      @page = if @current_project
        @current_project.pages.find(params[:page_id])
      else
        Page.find_by_id(params[:page_id], :conditions => {:project_id => current_user.project_ids})
      end
      api_status(:not_found) unless @page
    end
  end

  # Common api helpers
  
  def api_respond(object, options={})
    respond_to do |f|
      f.json { render :json => api_wrap(object, options).to_json }
      f.js   { render :json => api_wrap(object, options).to_json, :callback => params[:callback] }
    end
  end
  
  def api_status(status)
    respond_to do |f|
      f.json { head status }
      f.js   { render :json => {:status => status}.to_json, :status => status, :callback => params[:callback] }
    end
  end
  
  def api_wrap(object, options={})
    objects = if object.respond_to? :each
      object.map{|o| o.to_api_hash(options) }
    else
      object.to_api_hash(options)
    end
    
    if options[:references] || options[:reference_collections]
      { :objects => objects }.tap do |wrap|
        # List of messages to send to the object to get referenced objects
        if options[:references]
          wrap[:references] = Array(object).map do |obj|
            options[:references].map{|ref| obj.send(ref) }.flatten.compact
          end.flatten.uniq.map{|o| o.to_api_hash(options.merge(:emit_type => true))}
        end
        
        # List of messages to send to the object to get referenced objects as [:class, id]
        if options[:reference_collections]
          query = {}
          Array(object).each do |obj|
            options[:reference_collections].each do |ref|
              obj_query = obj.send(ref)
              if obj_query
                query[obj_query[0]] ||= []
                query[obj_query[0]] << obj_query[1]
              end
            end
          end
          
          wrap[:references] = (wrap[:references]||[]) + (query.map do |query_class, values|
            objects = Kernel.const_get(query_class).find(:all, :conditions => {:id => values.uniq})
            objects.uniq.map{|o| o.to_api_hash(options.merge(:emit_type => true))}
          end.flatten)
        end
      end
    else
      objects
    end
  end
  
  def api_error(the_message, status_code)
    the_list = {:errors => [{:message => the_message}]}
    respond_to do |f|
      f.json { render :json => the_list.to_json, :status => status_code }
      f.js { render :json => the_list.to_json, :status => status_code, :callback => params[:callback] }
    end
  end
  
  def handle_api_error(object,options={})
    the_list = {:errors => object.try(:errors)||[]}
    respond_to do |f|
      f.json { render :json => the_list.to_json, :status => options.delete(:status) || :unprocessable_entity }
      f.js   { render :json => the_list.to_json, :status => options.delete(:status) || :unprocessable_entity, :callback => params[:callback] }
    end
  end
  
  def handle_api_success(object,options={})
    respond_to do |f|
      if options.delete(:is_new) || false
        f.json { render :json => api_wrap(object, options).to_json, :status => options.delete(:status) || :created }
        f.js   { render :json => api_wrap(object, options).to_json, :status => options.delete(:status) || :created }
      else
        f.json { head(options.delete(:status) || :ok) }
        f.js   { render :json => {:status => options.delete(:status) || :ok}.to_json, :callback => params[:callback] }
      end
    end
  end
  
  def api_truth(value)
    ['true', '1'].include?(value) ? true : false
  end
  
  def api_limit
    if params[:count]
      [params[:count].to_i, API_LIMIT].min
    else
      API_LIMIT
    end
  end
  
  def api_range
    since_id = params[:since_id]
    max_id = params[:max_id]
    
    if since_id and max_id
      ['id > ? AND id < ?', since_id, max_id]
    elsif since_id
      ['id > ?', since_id]
    elsif max_id
      ['id < ?', max_id]
    else
      []
    end
  end
  
  def set_client
    request.format = :json unless request.format == :js
  end
  
end
