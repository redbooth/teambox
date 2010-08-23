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
                :load_organizations,
                :login_required, 
                :set_locale, 
                :touch_user, 
                :belongs_to_project?,
                :load_community_organization,
                :set_client
  
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
      if @current_project and logged_in?
        if current_user.projects.exists? @current_project
          # user is a project member
          unless @current_project.archived?
            current_user.add_recent_project(@current_project)
          end
        elsif @current_project.invitations.exists?(:invited_user_id => current_user)
          # there is an invitation pending for accept
          redirect_to project_invitations_path(@current_project)
        else
          # sorry, no dice
          render :template => 'projects/not_in_project', :status => :forbidden
        end
      end
    end

    def load_project
      if project_id = params[:project_id] || params[:id]
        unless @current_project = Project.find_by_id_or_permalink(project_id)
          flash[:error] = t('not_found.project', :id => project_id)
          redirect_to projects_path
        end
      end
    end

    # When you only belong to one organization, every page will be branded with its logo and colors.
    # If you belong to 2+ organizations, common pages will not be branded and others will be organization branded
    def load_organizations
      if logged_in? 
        @organizations = current_user.organizations
        @organization = case @organizations.size
        when 0
          current_user.projects.try(:first).try(:organization)
        when 1
          @organizations.first
        else
          @current_project.try(:organization)
        end
      end
    end

    def set_locale
      I18n.locale = logged_in? ? current_user.locale : user_agent_locale
    end
    
    LOCALES_REGEX = /\b(#{ I18n.available_locales.join('|') })\b/
    
    def user_agent_locale
      request.headers['HTTP_ACCEPT_LANGUAGE'].to_s =~ LOCALES_REGEX && $&
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
            user_name = @user.name
        end    
        @page_title = "#{user_name ? user_name + ' — ' : ''}#{translate_location_name}"
      end    
    end

    MobileClients = /(iPhone|iPod|Android|Opera mini|Blackberry|Palm|Windows CE|Opera mobi|iemobile|webOS)/i

    def set_client
      if [:html, :m].include?(request.format.to_sym) and session[:format]
        # Format has been forced by Sessions#change_format
        request.format = session[:format].to_sym
      else
        # We should autodetect mobile clients and redirect if they ask for html
        mobile =   request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][MobileClients]
        mobile ||= request.env["HTTP_PROFILE"] || request.env["HTTP_X_WAP_PROFILE"]
        if mobile and request.format == :html
          request.format = :m
        end
      end
    end
    
    def mobile?
      request.format == :m
    end
    helper_method :mobile?
    
    def iframe?
      params[:iframe] == 'true'
    end
    
    def output_errors_json(record)
      if request.xhr?
        response.content_type = Mime::JSON
        render :json => record.errors, :status => 400
      elsif iframe?
        render :template => 'shared/iframe_error', :layout => false, :locals => { :data => record.errors }
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
          super opts.merge(:text => content, :layout => false)
        elsif opts[:to_json] or opts[:as_json] then
          content = nil
          if opts[:to_json] then
            content = Hash.from_xml(render_to_string(:template => opts[:to_json], :layout => false)).to_json
          elsif opts[:as_json] then
            content = Hash.from_xml(opts[:as_json]).to_json
          end
          cbparam = params[:callback] || params[:jsonp]
          content = "#{cbparam}(#{content})" unless cbparam.blank?
          super opts.merge(:json => content, :layout => false)
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
    
    def calculate_position(obj)
      options = {}
      if pos = params[:position].presence
        options[:id] = pos[:slot].to_i
        if options[:id] < 0
          options[:id] = 0
          options[:before] = false
          options[:footer] = true
        else
          options[:before] = options[:id] == 0 ? true : (pos[:before].to_i == 1)
          options[:footer] = false
        end
      else
        options[:id] = nil
        options[:before] = true
        options[:footer] = false
      end
      obj.slot_insert = options
    end

    def signups_enabled?
      !Teambox.config.community || User.count == 0
    end

    def time_tracking_enabled?
      APP_CONFIG['allow_time_tracking'] || false
    end

    def load_community_organization
      if logged_in? and Teambox.config.community
        @community_organization = Organization.first
        @community_role = if @community_organization
          role_id = @community_organization.memberships.find_by_user_id(current_user.id).try(:role)
          Membership::ROLES.index(role_id)
        end
      end
    end

end
