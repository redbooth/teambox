module TasksHelper


  def remove_task(project,task_list,task)
    page["project_#{project.id}_task_list_#{task_list.id}_task_#{task.id}"].remove
  end

  def hide_task(project,task_list,task)
    page["project_#{project.id}_task_list_#{task_list.id}_task_#{task.id}"].hide
  end

  def show_task(project,task_list,task)
    page["project_#{project.id}_task_list_#{task_list.id}_task_#{task.id}"].show
  end

  def delete_task_link(project,task_list,task)
    link_to trash_image, project_task_list_task_path(project,task_list,task),
      :confirm => 'Are you sure you want to delete this task?', 
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

  def replace_task(project,task_list,task)
    page.replace "project_#{project.id}_task_list_#{task_list.id}_task_#{task.id}",
      :partial => 'tasks/task', 
      :locals => { 
        :project => project,
        :task_list => task_list,
        :task => task,
        :current_target => nil }
  end

  def insert_task(project,task_list,task)  
    page.insert_html :bottom, "project_#{project.id}_task_list_#{task_list.id}",
      :partial => 'tasks/task', 
      :locals => {  
        :task => task,
        :project => project, 
        :task_list => task_list,
        :current_target => nil }
  end

  def highlight_task(project,task_list,task)
    page["project_#{project.id}_task_list_#{task_list.id}_task_#{task.id}"].highlight
  end

  def list_tasks(project,task_list,tasks,current_target=nil)
    render :partial => 'tasks/task', 
      :collection => tasks,:locals => {
        :project => project,
        :task_list => task_list,
        :current_target => current_target }
  end

  def task_fields(f)
    render :partial => 'tasks/fields', :locals => { :f => f}
  end

end