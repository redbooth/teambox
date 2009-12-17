# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  rescue_from ActiveRecord::RecordNotFound, :with => :show_errors
  
  include AuthenticatedSystem
  include BannerSystem
  filter_parameter_logging :password

  before_filter :rss_token, 
                :confirmed_user?, 
                :load_project, 
                :login_required, 
                :set_locale, 
                :touch_user, 
                :recent_projects, 
                :belongs_to_project?, 
                :set_page_title
  
  private

    def check_permissions
      unless @current_project.editable?(current_user)
        render :text => "You don't have permission to edit/update/delete within \"#{@current_project.name}\" project", :status => :forbidden
      end
    end
    
    def show_errors
      render :partial => 'shared/record_not_found', :layout => 'application'
    end
    
    def confirmed_user?
      if current_user and not current_user.is_active?
        flash[:error] = "You need to activate your account first"
        redirect_to unconfirmed_email_user_path(current_user)
      end
    end
    
    def rss_token
      unless params[:rss_token].nil? or params[:format] != 'rss'
        user = User.find_by_rss_token(params[:rss_token])
        set_current_user user unless user.nil?
      end
    end

    def belongs_to_project?
      if @current_project && current_user
        unless Person.exists?(:project_id => @current_project.id, :user_id => current_user.id)
          current_user.remove_recent_project(@current_project)
          render :text => "You don't have permission to view this project", :status => :forbidden
        end
      end
    end
    
    def load_project
      project_id ||= params[:project_id]
      project_id ||= params[:id]
      
      if project_id
        @current_project = Project.find_by_permalink(project_id)
        
        if @current_project
          current_user.add_recent_project(@current_project) if current_user
        else        
          flash[:error] = "The project <i>#{h(project_id)}</i> doesn't exist."
          redirect_to projects_path, :status => 301
        end
      end
    end
    
    def recent_projects
      if logged_in?
        if current_user.recent_projects
          @recent_projects = current_user.recent_projects
        else
          @recent_projects = []
        end
      end
    end

    def set_locale
      # if this is nil then I18n.default_locale will be used
      I18n.locale = logged_in? ? current_user.language : 'en'
    end
    
    def touch_user
      current_user.touch if logged_in?
    end

    def set_page_title
      location_name = "#{params[:action]}_#{params[:controller]}"
      translate_location_name = t("page_title.#{location_name}")

      if params.has_key?(:id) && (location_name == 'show_projects' || 'edit_projects')
        #### I dont know why but this is breaking
        ##        
        #project_name = Project.find(params[:id],:select => 'name').name #Not working for some reason - .grab_name(params[:id])
        #@page_title = "&rarr; #{project_name} &rarr; #{translate_location_name}"
      elsif params.has_key?(:project_id)
        project_name = Project.grab_name_by_permalink(params[:project_id])
        name = nil
        case location_name
          when 'show_tasks'
            name = Task.grab_name(params[:id])
          when 'show_task_lists'
            name = TaskList.grab_name(params[:id])
          when 'show_conversations'
            name = Conversations.grab_name(params[:id])
        end  
        @page_title = "#{project_name} &rarr; #{ name ? name : translate_location_name }"
      else
        name = nil
        user_name = nil
        case location_name
          when 'edit_users'
            user_name = current_user.name
          when 'show_users'
            user_name = current_user.name            
        end    
        @page_title = "#{ "#{user_name} &rarr;" if user_name } #{translate_location_name}"
      end    
    end
    
    def split_events_by_date(events, start_date=nil)
      start_date ||= Date.today.monday.to_date
      return [] if events.empty?
      split_events = Array.new(14)
      events.each do |event|
        if (event.due_on - start_date) >= 0
          split_events[(event.due_on - start_date)] ||= []
          split_events[(event.due_on - start_date)] << event
        end
      end
      return split_events
    end    
end
