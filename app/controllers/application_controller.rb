# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  include AuthenticatedSystem
  filter_parameter_logging :password

  before_filter :confirmed_user?, :load_project, :login_required, :set_locale, :touch_user, :recent_projects, :belongs_to_project?
  
  private
    def confirmed_user?
      if current_user and not current_user.is_active?
        flash[:error] = "You need to activate your account first"
        redirect_to unconfirmed_email_user_path(current_user)
      end
    end

    def belongs_to_project?
      if @current_project and current_user
        unless Person.find_by_project_id_and_user_id(@current_project.id, current_user.id)
          current_user.remove_recent_project @current_project
          render :text => "You don't have permission to view this project", :status => :forbidden
        end
      end
    end
    
    def load_project
      project_id ||= params[:project_id]
      project_id ||= params[:id]
      
      if project_id
        @current_project = Project.find_by_permalink(project_id)
        
        if @current_project.nil?
          flash[:error] = "The project <i>#{h(project_id)}</i> doesn't exist."
          redirect_to projects_path, :status => 301
        else        
          current_user.add_recent_project(@current_project) unless current_user.nil?
        end
      end
    end
    
    def recent_projects
      if logged_in?
        unless current_user.recent_projects.nil?
          @recent_projects = current_user.recent_projects
        else
          @recent_projects = []
        end
      end
    end

    def set_locale
      # if this is nil then I18n.default_locale will be used
      I18n.locale = current_user.language if logged_in?
    end
    
    def touch_user
      current_user.touch if logged_in?
    end
    
end
