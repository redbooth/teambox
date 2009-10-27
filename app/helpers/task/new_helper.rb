module Task::NewHelper

  def insert_task(project,task_list,task)  
    page.insert_html :bottom, "project_#{project.id}_task_list_#{task_list.id}",
      :partial => 'tasks/task', 
      :locals => {  
        :task => task,
        :project => project, 
        :task_list => task_list,
        :current_target => nil }
  end

  def new_task_link(project,task_list)
    link_to_function '+ Add Task', show_new_task(project,task_list),
    :class => 'add_task_link',
    :id => task_id(:link,:new,project,task_list)
    
  end

  def new_task_form(project,task_list,task)
    render :partial => 'tasks/new', :locals => {
      :project => project,
      :task_list => task_list,
      :task => task }
  end
  
  def hide_new_task(project,task_list)
    update_page do |page|
      page.new_task(:link,:show,  project,task_list)
      page.new_task(:form,:hide,  project,task_list)
      page.new_task(:form,:reset, project,task_list)
    end  
  end

  def show_new_task(project,task_list)
    update_page do |page|
      page.new_task(:link,:hide,  project,task_list)
      page.new_task(:form,:show,  project,task_list)
      page.new_task(:form,:reset, project,task_list)
      page.new_task(:form,:focus, project,task_list)
    end  
  end
 
end