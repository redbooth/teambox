# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  include AuthenticatedSystem

  before_filter :load_project, :login_required, :set_locale, :touch_user, :recent_projects
  
  private
    def load_project
      if params[:project_id] != nil
        @current_project = Project.find_by_permalink(params[:project_id])
      end
    end
    
    def recent_projects
      if logged_in?
        unless current_user.recent_projects.nil?
          @recent_projects = Project.find(current_user.recent_projects)
        else
          []
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
    
    def save_uploads(target)
      if params[:uploads] != nil
        params[:uploads].each do |upload_id|
          upload = Upload.find(upload_id)
          if upload != nil
            upload.target_id = target.id
            upload.target_type = target.class.name
            upload.save
          end
        end
      end
    end
end
