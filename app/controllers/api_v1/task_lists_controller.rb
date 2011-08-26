class ApiV1::TaskListsController < ApiV1::APIController
  before_filter :load_task_list, :only => [:update,:show,:destroy,:archive,:unarchive]
  
  def index
    authorize! :show, @current_project||current_user
    
    context = if @current_project
      @current_project.task_lists.where(api_scope)
    else
      TaskList.joins(:project).where(:project_id => current_user.project_ids, :projects => {:archived => false}).where(api_scope)
    end
    
    @task_lists = context.except(:order).
                          where(api_range('task_lists')).
                          limit(api_limit).
                          order('task_lists.id DESC')
    
    # figure out which tasks we should reference
    task_includes = api_include & [:tasks, :unarchived_tasks, :archived_tasks]
    unless task_includes.empty?
      ref = "#{task_includes.first.to_s.singularize}_ids".to_sym
      @task_lists.each {|list| list.reference_task_objects = ref}
    end
    
    api_respond @task_lists, :references => true, :include => (api_include+[:task_ids])
  end

  def show
    authorize! :show, @task_list
    
    # figure out which tasks we should reference
    task_includes = api_include & [:tasks, :unarchived_tasks, :archived_tasks]
    unless task_includes.empty?
      ref = "#{task_includes.first.to_s.singularize}_ids".to_sym
      @task_list.reference_task_objects = ref
    end
    
    api_respond @task_list, :references => true, :include => (api_include+[:task_ids])
  end

  def create
    authorize! :make_task_lists, @current_project

    if params[:template_id].present?
      if template = @current_project.organization.task_list_templates.find(params[:template_id])
        @task_list = template.create_task_list(@current_project, current_user)
        @task_list.update_attribute :name, params[:name] unless params[:name].blank?
      end
    else
      @task_list = @current_project.create_task_list(current_user,params)
    end

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
    task_list_ids = params[:task_list_ids].to_s.split(',').collect(&:to_i)

    @current_project.task_lists.each do |t|
      next unless task_list_ids.include?(t.id)
      t.update_attribute :position, task_list_ids.index(t.id)
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
      @current_project.task_lists.find_by_id(params[:id])
    else
      TaskList.where(:project_id => current_user.project_ids).find_by_id(params[:id])
    end
    api_error :not_found, :type => 'ObjectNotFound', :message => 'TaskList not found' unless @task_list
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
    [:tasks, :unarchived_tasks, :archived_tasks, :uploads] & (params[:include]||[]).map(&:to_sym)
  end
end