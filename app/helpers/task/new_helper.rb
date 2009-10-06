module Task::NewHelper

  def new_task_link(project,task_list)
    link_to_function '+ Add Task', show_new_task(project,task_list),
    :class => 'add_task_link',
    :id => "project_#{project.id}_task_list_#{task_list.id}_new_task_link"
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

  def new_task(element,action,project,task_list)
    if action == :show
      page["project_#{project.id}_task_list_#{task_list.id}_new_task_#{element.to_s}"].show
    elsif action == :hide
      page["project_#{project.id}_task_list_#{task_list.id}_new_task_#{element.to_s}"].hide
    elsif element == :form
      if action == :reset
        page << "Form.reset('project_#{project.id}_task_list_#{task_list.id}_new_task_form')"
      elsif action == :focus
        page << "$('project_#{project.id}_task_list_#{task_list.id}_new_task_form').auto_focus()"
      end
    end
  end
 
end