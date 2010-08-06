class ApiV1::TasksController < ApiV1::APIController
  before_filter :load_task_list
  before_filter :load_task, :except => [:index, :create]
  before_filter :check_permissions, :except => [:index, :show]
  
  def index
    if @current_project
      @tasks = (@task_list || @current_project).tasks.scoped(api_scope).all(:conditions => api_range, :limit => api_limit)
    else
      @tasks = Task.scoped(api_scope).find_all_by_project_id(current_user.project_ids, :conditions => api_range, :limit => api_limit)
    end
    
    api_respond @tasks.to_json
  end

  def show
    api_respond @task.to_json
  end
  
  def create
    if @task = @current_project.create_task(current_user,@task_list,params[:task])
      unless @task.new_record?
        @comment = @current_project.new_task_comment(@task)
        @task.reload
      end
    end
    
    if @task.new_record?
      handle_api_error(@task)
    else
      handle_api_success(@task, :is_new => true)
    end
  end
  
  def update
    @saved = @task.update_attributes(params[:task])
    
    if @saved
      handle_api_success(@task)
    else
      handle_api_error(@task)
    end
  end

  def destroy
    @task.destroy
    handle_api_success(@task)
  end

  def watch
    @task.add_watcher(current_user)
    handle_api_success(@task)
  end

  def unwatch
    @task.remove_watcher(current_user)
    handle_api_success(@task)
  end
  
  def reorder
    new_task_ids_for_task_list = (params[:tasks] || []).reject { |task_id| task_id.blank? }.map(&:to_i)
    moved_task_ids = new_task_ids_for_task_list.to_set - @task_list.task_ids.to_set
    moved_task_ids.each do |moved_task_id|
      Task.find(moved_task_id).update_attribute(:task_list, @task_list)
    end
    new_task_ids_for_task_list.each_with_index do |task_id,idx|
      task = @task_list.tasks.find(task_id)
      task.update_attribute(:position,idx.to_i)
    end
    
    api_status(:ok)
  end

  protected
  
  def load_task
    @task = if @current_project
      (@task_list || @current_project).tasks.find(params[:id]) rescue nil
    else
      Task.find(params[:id], :conditions => {:project_id => current_user.project_ids})
    end
    api_status(:not_found) unless @task
  end
  
  def api_scope
    conditions = {}
    unless params[:status].nil?
      conditions[:status] = Array(params[:status]).map(&:to_i).uniq[0..4]
    end
    {:conditions => conditions}
  end
  
  def check_permissions
    # Can they even edit the project?
    unless @current_project.editable?(current_user)
      api_error(t('common.not_allowed'), :unauthorized)
    end
  end
end