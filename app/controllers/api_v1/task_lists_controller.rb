class ApiV1::TaskListsController < ApiV1::APIController
  before_filter :load_task_list, :only => [:edit,:update,:show,:destroy,:watch,:unwatch,:archive,:unarchive]
  before_filter :check_permissions, :only => [:new,:create,:edit,:update,:destroy,:archive,:unarchive]
  

  def index
    respond_to do |f|
      f.json  { render :as_json => @task_lists.to_xml(:include => :tasks, :root => 'task-lists') }
    end
  end

  def show
    respond_to do |f|
      f.json  { render :as_json => @task_list.to_xml(:include => [:tasks, :comments]) }
    end
  end

  def create
    @task_list = @current_project.create_task_list(current_user,params[:task_list])
    
    respond_to do |f|
      if !@task_list.new_record?
        handle_api_success(f, @task_list, true)
      else
        handle_api_error(f, @task_list)
      end
    end
  end

  def update
    @saved = @task_list.update_attributes(params[:task_list])
    
    respond_to do |f|
      if @saved
        handle_api_success(f, @task_list)
      else
        handle_api_error(f, @task_list)
      end
    end
  end

  def reorder
    params[:task_lists].each_with_index do |task_list_id,idx|
      @task_list = @current_project.task_lists.find(task_list_id)
      @task_list.update_attribute(:position,idx.to_i)
    end
    
    respond_to do |f|
      handle_api_success(f, @task_list)
    end
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
      
      respond_to do |f|
        handle_api_success(f, @task_list)
      end
    else
      respond_to do |f|
        handle_api_error(f, @task_list)
      end
    end
  end
  
  def unarchive
    if request.method == :put and @task_list.editable?(current_user) and @task_list.archived
      @task_list.archived = false
      @saved = @task_list.save
    end
    
    respond_to do |f|
      if @saved
        handle_api_success(f, @task_list)
      else
        handle_api_error(f, @task_list)
      end
    end
  end

  def destroy
    @has_permission = if @task_list.editable?(current_user)
      @task_list.try(:destroy)
      true
    else
      false
    end
    
    respond_to do |f|
      if @has_permission
        handle_api_success(f, @task_list)
      else
        handle_api_error(f, @task_list)
      end
    end
  end

  def watch
    @task_list.add_watcher(current_user)
    respond_to do |f|
      handle_api_success(f, @task_list)
    end
  end

  def unwatch
    @task_list.remove_watcher(current_user)
    respond_to do |f|
      handle_api_success(f, @task_list)
    end
  end
  
  private

    def load_task_list
      @task_list = @current_project.task_lists.find(params[:id])
    end
    
    def check_permissions
      # Can they even edit the project?
      unless @current_project.editable?(current_user)
        api_error(t('common.not_allowed'), :unprocessable_entity)
        return false
      end
    end
  
end