class ApiV1::TasksController < ApiV1::APIController
  before_filter :load_task_list, :only => [:index, :show, :reorder]
  before_filter :load_or_create_task_list, :only => [:create]
  before_filter :load_task, :except => [:index, :create, :reorder]
  
  def index
    authorize! :show, @task_list||@current_project||current_user
    
    context = if @current_project
      (@task_list || @current_project).tasks.where(api_scope)
    else
      Task.joins(:project).where(:project_id => current_user.project_ids, :projects => {:archived => false}).where(api_scope)
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
      handle_api_success(@task, :is_new => true, :references => true, :include => [:user, :uploads, :google_docs])
    end
  end
  
  def update
    if can? :update, @task
      @task.updating_user = current_user
      success = @task.update_attributes params
    elsif can? :comment, @task
      @task.updating_user = current_user
      success = @task.update_attributes(:comments_attributes => params['comments_attributes']||{})
    else
      authorize! :comment, @task
    end

    if success
      handle_api_success(@task, :wrap_objects => true, :references => true, :include => [:user, :uploads, :google_docs])
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
    @task = Task.find_by_id(params[:id])
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Task not found' unless @task && (current_user.project_ids.include?(@task.project_id))
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Task not found' if @task_list && @task.task_list_id != @task_list.id
  end
  
  def load_or_create_task_list
    if params[:task_list_id] or @current_project.nil?
      load_task_list
    else
      # make or load inbox
      @task_list = TaskList.find_or_create_by_name_and_project_id_and_user_id('Inbox', @current_project.id, @current_project.user_id)
    end
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
