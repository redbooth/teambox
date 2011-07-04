class ApiV1::TasksController < ApiV1::APIController
  before_filter :load_task_list
  before_filter :load_task, :except => [:index, :create, :reorder]
  
  def index
    authorize! :show, @task_list||@current_project||current_user
    
    context = if @current_project
      (@task_list || @current_project).tasks.where(api_scope)
    else
      Task.where(:project_id => current_user.project_ids).where(api_scope)
    end
    
    @tasks = context.except(:order).
                     where(api_range('tasks')).
                     where(['is_private = ? OR (is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
                     joins("LEFT JOIN watchers ON (tasks.id = watchers.watchable_id AND watchers.watchable_type = 'Task') AND watchers.user_id = #{current_user.id}").
                     limit(api_limit).
                     order('tasks.id DESC')
    
    api_respond @tasks, :references => true
  end

  def show
    authorize! :show, @task
    api_respond @task, :include => api_include, :references => true
  end
  
  def create
    authorize! :make_tasks, @current_project
    @task = @task_list.tasks.build_by_user(current_user, params)
    @task.is_private = (params[:task][:is_private]||false) if params[:task]
    @task.save
    
    if @task.new_record?
      handle_api_error(@task)
    else
      handle_api_success(@task, :is_new => true, :include => [:comments])
    end
  end
  
  def update
    authorize! :update, @task
    @task.updating_user = current_user
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
    begin
      @task = @current_project.tasks.find(params[:id])
      if @task.task_list != @task_list
        @task.task_list = @task_list
        @task.save
      end

      task_ids = params[:task_ids].split(',').collect(&:to_i)
      @task_list.tasks.each do |t|
        next unless task_ids.include?(t.id)
        Task.thin_model.find(t.id).update_attribute :position, task_ids.index(t.id)
      end
    rescue ActiveRecord::RecordNotFound
      return api_error :not_found, :type => 'ObjectNotFound', :message => 'Task not found' unless @task
    end

    api_status(:ok)
  end

  protected
  
  def load_task
    @task = if @current_project
      (@task_list || @current_project).tasks.find_by_id(params[:id]) rescue nil
    else
      Task.where(:project_id => current_user.project_ids).find_by_id(params[:id])
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
    unless params[:assigned_user_id].nil?
      conditions[:assigned_id] = Person.select('id').find_all_by_user_id(params[:assigned_user_id]).map(&:id)
    end
    conditions
  end
    
  def api_include
    [:comments, :user, :assigned, :uploads] & (params[:include]||{}).map(&:to_sym)
  end
end