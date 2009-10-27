module TasksHelper
  def update_task_status(task)
    page.replace 'task_status', task_status(task) if task.class.to_s == 'Task'
  end

  def task_status(task)
    "<span id='task_status' class='task_status task_status_#{Task::STATUSES[task.status.to_i].underscore}'>#{Task::STATUSES[task.status.to_i].capitalize}</span>"
  end
  
  def my_tasks_link
    link_to 'My Tasks', ''
  end
  
  def remove_task(project,task_list,task)
    page[task_id(:single,:item,project,task_list,task)].remove
  end

  def hide_task(project,task_list,task)
    page[task_id(:single,:item,project,task_list,task)].hide
  end

  def show_task(project,task_list,task)
    page[task_id(:single,:item,project,task_list,task)].show
  end

  def delete_task_link(project,task_list,task)
    link_to t('common.delete'), project_task_list_task_path(project,task_list,task),
      :confirm => t('confirm.delete_task'), 
      :method => :delete
  end

  def task_action_links(project,task_list,task)
    if task.owner?(current_user)
      render :partial => 'tasks/actions',
      :locals => { 
        :project => project,
        :task_list => task_list,
        :task => task }
    end
  end

  def task_drag_link(project,task_list,task)
    if task.owner?(current_user)
      render :partial => 'tasks/drag_action',
      :locals => { 
        :project => project,
        :task_list => task_list,
        :task => task }
    end
  end

  def list_tasks(project,task_list,tasks,current_target=nil)
    render :partial => 'tasks/task', 
      :collection => tasks,:locals => {
        :project => project,
        :task_list => task_list,
        :current_target => current_target }
  end

  def task_fields(f)
    render :partial => 'tasks/fields', :locals => { :f => f }
  end

  def task_id(element,controller_action,project,task_list,task=nil)
    if task
      "project_#{project.id}_task_list_#{task_list.id}_#{controller_action}_task_#{task.id}_#{element.to_s}"
    else
      "project_#{project.id}_task_list_#{task_list.id}_#{controller_action}_task_#{element.to_s}"
    end
  end

  def item_task(action,project,task_list,task)
    rjs_task_master(:item,:single,action,project,task_list,task)
  end

  def edit_task(element,action,project,task_list)
    rjs_task_master(:edit,element,action,project,task_list,nil)
  end
  
  def new_task(element,action,project,task_list)
    rjs_task_master(:new,element,action,project,task_list,nil)
  end
    
  def rjs_task_master(ca,e,action,p,tl,t)
    case action
      when :show
        page[task_id(e,ca,p,tl,t)].show
      when :hide
        page[task_id(e,ca,p,tl,t)].hide
      when :show
        page[task_id(e,ca,p,tl,t)].remove
      when :highlight
        page[task_id(e,ca,p,tl,t)].highlight
      when :reset
        if e == :form
          page << "Form.reset('#{task_id(:form,ca,p,tl,t)}')"
        end  
      when :focus
        if e == :form
          page << "$('#{task_id(:form,ca,p,tl,t)}').auto_focus()"
        end
    end
  end
  
  def task_list_primer(project)
    render :partial => 'task_lists/primer', :locals => { :project => project }
  end
end