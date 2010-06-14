# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  include AuthenticatedSystem
  include SslHelper

  filter_parameter_logging :password

  before_filter :rss_token, 
                :confirmed_user?, 
                :load_project, 
                :login_required, 
                :set_locale, 
                :touch_user, 
                :belongs_to_project?,
                :set_client,
                :set_user
  
  private
    def check_permissions
      unless @current_project.editable?(current_user)
        render :text => "You don't have permission to edit/update/delete within \"#{@current_project.name}\" project", :status => :forbidden
      end
    end
    
    def confirmed_user?
      if current_user and not current_user.is_active?
        redirect_to unconfirmed_email_user_path(current_user)
      end
    end
    
    def rss_token
      unless params[:rss_token].nil? or !%w(rss ics).include?(params[:format])
        user = User.find_by_rss_token(params[:rss_token])
        set_current_user user if user
      end
    end

    def belongs_to_project?
      if @current_project && current_user
        unless Person.exists?(:project_id => @current_project.id, :user_id => current_user.id)
          if Invitation.exists?(:project_id => @current_project.id, :invited_user_id => current_user.id)
            redirect_to project_invitations_path(@current_project)
          else 
            current_user.remove_recent_project(@current_project)
            render :text => "You don't have permission to view this project", :status => :forbidden
          end
        end
      end
    end
    
    def load_group
      group_id ||= params[:group_id]
      
      if group_id
        @current_group = Group.find_by_permalink(group_id)
        
        if @current_group
          # ...
        else
          flash[:error] = t('not_found.group', :id => group_id)
          redirect_to groups_path, :status => 301
        end
      end
    end
    
    def load_project
      project_id ||= params[:project_id]
      project_id ||= params[:id]
      
      if project_id
        @current_project = Project.find_by_permalink(project_id)
        
        if @current_project
          if current_user && !@current_project.archived?
            current_user.add_recent_project(@current_project)
          end
        else
          flash[:error] = t('not_found.project', :id => project_id)
          redirect_to projects_path, :status => 301
        end
      end
    end
    
    def set_locale
      # if this is nil then I18n.default_locale will be used
      I18n.locale = logged_in? ? current_user.language : get_browser_locale
    end
    
    LOCALES_REGEX = /\b(#{ I18n.available_locales.map(&:to_s).join('|') })\b/
    
    def get_browser_locale
      if request.headers['HTTP_ACCEPT_LANGUAGE'].to_s =~ LOCALES_REGEX
        $&
      else
        I18n.default_locale
      end
    end
    
    def fragment_cache_key(key)
      super(key).tap { |str|
        str << "_#{I18n.locale}"
        if logged_in? and current_user.time_zone?
          str << "-#{current_user.time_zone.gsub(/\W/,'')}"
        end
      }
    end
    
    def touch_user
      current_user.update_visited_at if logged_in?
    end

    def set_page_title
      location_name = "#{params[:action]}_#{params[:controller]}"
      translate_location_name = t("page_title.#{location_name}", :default => '')

      if params.has_key?(:id) && ['show_projects','edit_projects'].include?(location_name)
        project_name = @current_project.name
        @page_title = "#{project_name} — #{translate_location_name}"
      elsif params.has_key?(:project_id)
        project_name = @current_project.name
        name = nil
        case location_name
          when 'show_tasks'
            name = @task ? @task.name : nil
          when 'show_task_lists'
            name = @task_list ? @task_list.name : nil
          when 'show_conversations'
            name = @conversation ? @conversation.name : nil
          when 'show_pages'
            name = @page ? @page.name : nil
        end
        @page_title = "#{project_name} — #{name || translate_location_name}"
      else
        name = nil
        user_name = nil
        case location_name
          when 'edit_users'
            user_name = current_user.name
          when 'show_users'
            user_name = current_user.name            
        end    
        @page_title = "#{user_name ? user_name + ' — ' : ''}#{translate_location_name}"
      end    
    end

    MobileClients = /(iPhone|iPod|Android|Opera mini|Blackberry|Palm|Windows CE|Opera mobi|iemobile|webOS)/i

    def set_client
      mobile =   request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][MobileClients]
      mobile ||= request.env["HTTP_PROFILE"] || request.env["HTTP_X_WAP_PROFILE"]
      if mobile and request.format == :html
        request.format = :m
      end
    end
    
    def split_events_by_date(events, start_date=nil)
      start_date ||= Date.today.monday.to_date
      split_events = Array.new
      Array(events).each do |event|
        if (event.due_on - start_date) >= 0
          split_events[(event.due_on - start_date)] ||= []
          split_events[(event.due_on - start_date)] << event
        end
      end
      split_events
    end
    
    # http://www.coffeepowered.net/2009/02/16/powerful-easy-dry-multi-format-rest-apis-part-2/
    def render(opts = nil, extra_options = {}, &block)
      if opts && opts.is_a?(Hash) then
        if opts[:to_yaml] or opts[:as_yaml] then
          headers["Content-Type"] = "text/plain;"
          text = nil
          if opts[:as_yaml] then
            text = Hash.from_xml(opts[:as_yaml]).to_yaml
          else
            text = Hash.from_xml(render_to_string(:template => opts[:to_yaml], :layout => false)).to_yaml
          end
          super :text => text, :layout => false
        elsif opts[:to_json] or opts[:as_json] then
          content = nil
          if opts[:to_json] then
            content = Hash.from_xml(render_to_string(:template => opts[:to_json], :layout => false)).to_json
          elsif opts[:as_json] then
            content = Hash.from_xml(opts[:as_json]).to_json
          end
          cbparam = params[:callback] || params[:jsonp]
          content = "#{cbparam}(#{content})" unless cbparam.blank?
          super :json => content, :layout => false
        else
          super(opts, extra_options, &block)
        end
      else
        super(opts, extra_options, &block)
      end
    end
    
    def handle_api_error(f,object)
      error_list = object.nil? ? [] : object.errors
      f.xml  { render :xml => error_list.to_xml,     :status => :unprocessable_entity }
      f.json { render :as_json => error_list.to_xml, :status => :unprocessable_entity }
      f.yaml { render :as_yaml => error_list.to_xml, :status => :unprocessable_entity }
    end
    
    def handle_api_success(f,object,is_new=false)
      if is_new
        f.xml  { render :xml => object.to_xml, :status => :created }
        f.json { render :as_json => object.to_xml, :status => :created }
        f.yaml { render :as_yaml => object.to_xml, :status => :created }
      else
        f.xml  { head :ok }
        f.json { head :ok }
        f.yaml { head :ok }
      end
    end
    
    def set_user
      @current_user = current_user || nil
    end
    
    def calculate_position
      if pos = params[:position].presence
        @insert_id = pos[:slot].to_i
        if @insert_id < 0
          @insert_id = 0
          @insert_before = false
          @insert_footer = true
        else
          @insert_before = @insert_id == 0 ? true : (pos[:before].to_i == 1)
          @insert_footer = false
        end
      else
        @insert_id = nil
        @insert_before = true
        @insert_footer = false
      end
    end
    
    def save_slot(obj)
      @slot = obj.page.new_slot(@insert_id, @insert_before, obj)

      if @insert_footer
        @insert_element = nil
        @insert_before = true
      else
        @insert_element = @insert_id == 0 ? nil : "page_slot_#{@insert_id}"
      end
    end
    
    def signups_enabled?
      APP_CONFIG['allow_signups'] || User.count == 0
    end
    
    def groups_enabled?
      !!Teambox.config.allow_groups
    end
    helper_method :groups_enabled?
    
    def time_tracking_enabled?
      APP_CONFIG['allow_time_tracking'] || false
    end

end
