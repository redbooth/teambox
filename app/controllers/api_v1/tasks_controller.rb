class ApiV1::TasksController < ApiV1::APIController
  before_filter :load_task_list
  before_filter :load_task, :except => [:index, :create, :reorder]
  
  def index
    query = {:conditions => api_range,
             :limit => api_limit,
             :order => 'id DESC',
             :include => [:task_list, :project, :user, :assigned,
                         {:first_comment => :user}, {:recent_comments => :user}]}
    
    if @current_project
      @tasks = (@task_list || @current_project).tasks.where(api_scope).all(query)
    else
      @tasks = Task.where(api_scope).find_all_by_project_id(current_user.project_ids, query)
    end
    
    api_respond @tasks, :references => [:task_list, :project, :user, :assigned, :refs_comments]
  end

  def show
    api_respond @task, :include => api_include
  end
  
  def create
    authorize! :make_tasks, @current_project
    @task = @task_list.tasks.create_by_user(current_user, params)
    
    if @task.new_record?
      handle_api_error(@task)
    else
      handle_api_success(@task, :is_new => true, :include => [:comments])
    end
  end
  
  def update
    authorize! :update, @task
    if @task.update_attributes(params)
      handle_api_success(@task)
    else
      handle_api_error(@task)
    end
  end

  def destroy
    authorize! :destroy, @task
    @task.destroy
    handle_api_success(@task)
  end

  def watch
    authorize! :watch, @task
    @task.add_watcher(current_user)
    handle_api_success(@task)
  end

  def unwatch
    @task.remove_watcher(current_user)
    handle_api_success(@task)
  end
  
  def reorder
    authorize! :reorder_objects, @current_project
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
      Task.find_by_id(params[:id], :conditions => {:project_id => current_user.project_ids})
    end
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Task not found' unless @task
  end
  
  def api_scope
    conditions = {}
    unless params[:status].nil?
      conditions[:status] = Array(params[:status]).map(&:to_i).uniq[0..4]
    end
    unless params[:user_id].nil?
      conditions[:user_id] = params[:user_id].to_i
    end
    unless params[:assigned_id].nil?
      conditions[:assigned_id] = params[:assigned_id].to_i
    end
    conditions
  end
    
  def api_include
    [:comments, :user, :assigned] & (params[:include]||{}).map(&:to_sym)
  end
end