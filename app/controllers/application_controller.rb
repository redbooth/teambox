# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  include AuthenticatedSystem

  filter_parameter_logging :password

  before_filter :load_project, :login_required, :set_locale, :touch_user, :recent_projects, :belongs_to_project?
  
  private
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
        
        unless @current_project.nil? or current_user.nil?
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
    
    def set_year_month(year,month)
      @year = year
      @month = month
      @comments = @current_project.comments.with_hours.find_by_month(@month,@year)
    end
end
