class ApiV1::APIController < ApplicationController
  skip_before_filter :rss_token, :recent_projects, :touch_user, :verify_authenticity_token

  API_LIMIT = 25

  protected
  
  def load_project
    project_id ||= params[:project_id]
    
    if project_id
      @current_project = Project.find_by_permalink(project_id)
      api_status(:not_found) unless @current_project
    end
  end
  
  def belongs_to_project?
    if @current_project
      unless Person.exists?(:project_id => @current_project.id, :user_id => current_user.id)
        api_error(t('common.not_allowed'), :unauthorized)
      end
    end
  end
  
  def check_permissions
    unless @current_project.editable?(current_user)
      api_error("You don't have permission to edit/update/delete within \"#{@current_project}\" project", :unauthorized)
    end
  end
  
  def load_task_list
    if @current_project && params[:task_list_id]
      @task_list = @current_project.task_lists.find(params[:task_list_id])
    end
  end
  
  def load_page
    @page = @current_project.pages.find params[:page_id]
    api_status(:not_found) unless @page
  end

  # Common api helpers
  
  def api_respond(json)
    respond_to do |f|
      f.json { render :json => json }
    end
  end
  
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
  
  def handle_api_error(object,options={})
    error_list = object.nil? ? [] : object.errors
    respond_to do |f|
      f.json { render :as_json => error_list.to_xml, :status => options.delete(:status) || :unprocessable_entity }
    end
  end
  
  def handle_api_success(object,options={})
    respond_to do |f|
      if options.delete(:is_new) || false
        f.json { render :json => object.to_json, :status => options.delete(:status) || :created }
      else
        f.json { head(options.delete(:status) || :ok) }
      end
    end
  end
  
  def api_limit
    [params[:count].to_i, API_LIMIT].max
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
    request.format = :json
  end
  
end