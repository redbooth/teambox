class ApiV1::TaskListsController < ApiV1::APIController
  before_filter :load_task_list, :only => [:update,:show,:destroy,:archive,:unarchive]
  before_filter :check_permissions, :only => [:create,:update,:destroy,:archive,:unarchive]
  
  def index
    params = {:conditions => api_range, :limit => api_limit, :include => [:user, :project]}
    
    @task_lists = if @current_project
      @current_project.task_lists.scoped(api_scope).all(params)
    else
      TaskList.scoped(api_scope).find_all_by_project_id(current_user.project_ids, params)
    end
    
    api_respond @task_lists, :include => [:user, :project], :references => [:user, :project]
  end

  def show
    api_respond @task_list, :include => api_include
  end

  def create
    @task_list = @current_project.create_task_list(current_user,params[:task_list])
    
    if @task_list.new_record?
      handle_api_error(@task_list)
    else
      handle_api_success(@task_list, :is_new => true)
    end
  end

  def update
    @saved = @task_list.update_attributes(params[:task_list])
    
    if @saved
      handle_api_success(@task_list)
    else
      handle_api_error(@task_list)
    end
  end

  def reorder
    params[:task_lists].each_with_index do |task_list_id,idx|
      @task_list = @current_project.task_lists.find(task_list_id)
      @task_list.update_attribute(:position,idx.to_i)
    end
    
    handle_api_success(@task_list)
  end
  
  def archive
    if request.method == :put and !@task_list.archived
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
    if request.method == :put and @task_list.editable?(current_user) and @task_list.archived
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
      api_status(:not_found) unless @task_list
    end
    
    def api_scope
      conditions = {}
      unless params[:archived].nil?
        conditions[:archived] = api_truth(params[:archived])
      end
      {:conditions => conditions}
    end
    
    def check_permissions
      # Can they even edit the project?
      unless @current_project.editable?(current_user)
        api_error(t('common.not_allowed'), :unauthorized)
      end
    end
    
    def api_include
      [:tasks, :comments] & (params[:include]||{}).map(&:to_sym)
    end
end