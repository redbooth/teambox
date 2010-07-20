class ApiV1::APIController < ApplicationController
  skip_before_filter :load_project, :belongs_to_project?, :rss_token, :recent_projects, :touch_user
  before_filter :api_load_project, :api_belongs_to_project?

  protected
  
  def api_load_project
    project_id ||= params[:project_id]
    
    if project_id
      @current_project = Project.find_by_permalink(project_id)
      
      unless @current_project
        api_status(:not_found)
      end
    end
  end
  
  def api_belongs_to_project?
    if @current_project
      unless Person.exists?(:project_id => @current_project.id, :user_id => current_user.id)
        api_error(t('common.not_allowed'), :unauthorized)
      end
    end
  end

  # Common api helpers
  
  def api_status(status)
    respond_to do |f|
      f.json { head status }
    end
  end
  
  def api_error(message, status)
    error = {'message' => message}
    respond_to do |f|
      f.json { render :as_json => error.to_xml(:root => 'error'), :status => status }
    end
  end
  
  def handle_api_error(f,object,options={})
    error_list = object.nil? ? [] : object.errors
    f.json { render :as_json => error_list.to_xml, :status => options.delete(:status) || :unprocessable_entity }
  end
  
  def handle_api_success(f,object,options={})
    if options.delete(:is_new)
      f.json { render :as_json => object.to_xml, :status => options.delete(:status) || :created }
    else
      f.json { head(options.delete(:status) || :ok) }
    end
  end
end