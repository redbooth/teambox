# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  include AuthenticatedSystem

  filter_parameter_logging :password

  before_filter :load_project, :login_required, :set_locale, :touch_user, :recent_projects
  
  private
    def load_project
      if params[:project_id] != nil
        @current_project = Project.find_by_permalink(params[:project_id])
        unless @current_project.nil?
          current_user.add_recent_project(@current_project)
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
