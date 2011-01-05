class ApiV1::TaskListsController < ApiV1::APIController
  before_filter :load_task_list, :only => [:update,:show,:destroy,:archive,:unarchive]
  
  def index
    query = {:conditions => api_range,
             :limit => api_limit,
             :order => 'id DESC',
             :include => [:user, :project]}
    
    @task_lists = if @current_project
      @current_project.task_lists.where(api_scope).all(query)
    else
      TaskList.where(api_scope).find_all_by_project_id(current_user.project_ids, query)
    end
    
    api_respond @task_lists, :include => [:user, :project], :references => [:user, :project]
  end

  def show
    api_respond @task_list, :include => api_include
  end

  def create
    authorize! :make_task_lists, @current_project
    @task_list = @current_project.create_task_list(current_user,params)
    
    if @task_list.new_record?
      handle_api_error(@task_list)
    else
      handle_api_success(@task_list, :is_new => true)
    end
  end

  def update
    authorize! :update, @task_list
    @saved = @task_list.update_attributes(params)
    
    if @saved
      handle_api_success(@task_list)
    else
      handle_api_error(@task_list)
    end
  end

  def reorder
    authorize! :reorder_objects, @current_project
    params[:task_lists].each_with_index do |task_list_id,idx|
      @task_list = @current_project.task_lists.find(task_list_id)
      @task_list.update_attribute(:position,idx.to_i)
    end
    
    handle_api_success(@task_list)
  end
  
  def archive
    authorize! :update, @task_list
    unless @task_list.archived
      # Prototype for comment
      comment_attrs = {:comment_body => params[:message]}
      comment_attrs[:body] ||= "Archived task list"
      comment_attrs[:status] = params[:status] || 3
      
      # Resolve all unresolved tasks
      @task_list.tasks.each do |task|
        if !task.archived?
          task.previous_status = task.status
          task.previous_assigned_id = task.assigned_id
          task.status = comment_attrs[:status]
          task.assigned_id = nil
          comment = @current_project.new_comment(current_user,task,comment_attrs)
          comment.save!
        end
      end
      
      @task_list.reload
      @task_list.archived = true
      @task_list.save!
      
      handle_api_success(@task_list)
    else
      handle_api_error(@task_list)
    end
  end
  
  def unarchive
    authorize! :update, @task_list
    if @task_list.archived
      @task_list.archived = false
      @saved = @task_list.save
    end
    
    if @saved
      handle_api_success(@task_list)
    else
      handle_api_error(@task_list)
    end
  end

  def destroy
    authorize! :destroy, @task_list
    @task_list.destroy
    handle_api_success(@task_list)
  end
  
  protected
  
  def load_task_list
    @task_list = if @current_project
      @current_project.task_lists.find(params[:id])
    else
      TaskList.find_by_id(params[:id], :conditions => {:project_id => current_user.project_ids})
    end
    api_status(:not_found) if @task_list.nil?
  end
    
  def api_scope
    conditions = {}
    unless params[:archived].nil?
      conditions[:archived] = api_truth(params[:archived])
    end
    unless params[:user_id].nil?
      conditions[:user_id] = params[:user_id].to_i
    end
    conditions
  end
  
  def api_include
    [:tasks, :comments] & (params[:include]||{}).map(&:to_sym)
  end
end