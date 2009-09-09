module TasksHelper

  def remove_task(project,task_list,task)
    page["project_#{project.id}_task_list_#{task_list.id}_task_#{task.id}"].remove
  end

  def new_task_link(project,task_list)
    link_to_function '+ Add Task', show_new_task(project,task_list),
    :class => 'add_task_link',
    :id => "project_#{project.id}_task_list_#{task_list.id}_new_task_link"
  end

  def hide_new_task(project,task_list)
    update_page do |page|
      page.show_new_task_link(project,task_list)
      page.hide_new_task_form(project,task_list)
      page.reset_new_form(project,task_list)
    end  
  end

  def reset_new_form(project,task_list)
    page << "Form.reset('project_#{project.id}_task_list_#{task_list.id}_new_task')"
  end  

  def show_new_task(project,task_list)
    update_page do |page|
      page.hide_new_task_link(project,task_list)
      page.show_new_task_form(project,task_list)
      page.reset_new_form(project,task_list)
    end  
  end

  def show_edit_task(project,task_list,task)
    update_page do |page|
      page.show_edit_task_form(project,task_list,task)
      page.hide_task(project,task_list,task)
    end
  end

  def hide_edit_task(project,task_list,task)
    update_page do |page|
      page.hide_edit_task_form(project,task_list,task)
      page.show_task(project,task_list,task)
    end    
  end
  
  def hide_task(project,task_list,task)
    page["project_#{project.id}_task_list_#{task_list.id}_task_#{task.id}"].hide
  end
  
  def show_task(project,task_list,task)
    page["project_#{project.id}_task_list_#{task_list.id}_task_#{task.id}"].show
  end
    
  def hide_new_task_link(project,task_list)
    page["project_#{project.id}_task_list_#{task_list.id}_new_task_link"].hide
  end

  def show_new_task_link(project,task_list)
    page["project_#{project.id}_task_list_#{task_list.id}_new_task_link"].show
  end

  def hide_new_task_form(project,task_list)
    page["project_#{project.id}_task_list_#{task_list.id}_new_task"].hide
  end

  def show_new_task_form(project,task_list)
    page["project_#{project.id}_task_list_#{task_list.id}_new_task"].show
  end

  def hide_edit_task_form(project,task_list,task)
    page["project_#{project.id}_task_list_#{task_list.id}_edit_task_#{task.id}"].hide
  end
  
  def show_edit_task_form(project,task_list,task)
    page["project_#{project.id}_task_list_#{task_list.id}_edit_task_#{task.id}"].show
  end

  def task_action_links(project,task_list,task)
    if logged_in?
      if task.owner?(current_user)
        render :partial => 'tasks/actions',
        :locals => { 
          :project => project,
          :task_list => task_list,
          :task => task }
      end
    end
  end

  def remove_edit_task_form(project,task_list,task)
    page["project_#{project.id}_task_list_#{task_list.id}_edit_task_#{task.id}"].remove
  end

  def replace_new_task_form(project,task_list)
    page.replace "project_#{project.id}_task_list_#{task_list.id}_new_task",
      :partial => 'tasks/new', 
      :locals => { 
        :task => Task.new, 
        :project => project, 
        :task_list => task_list }
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

  def new_task_form(project,task_list,task)
    render :partial => 'tasks/new', :locals => {
      :project => project,
      :task_list => task_list,
      :task => task }
  end

  def edit_task_form(project,task_list,task)
    render :partial => 'tasks/edit', :locals => {
      :project => project,
      :task_list => task_list,
      :task => task }
  end
  
end
