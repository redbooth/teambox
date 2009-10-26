module Task::EditHelper

  def edit_task_link(project, task_list, task)
    link_to_function t('common.edit'), show_edit_task(project,task_list,task)
  end

  def hide_edit_task_form(project, task_list, task)
    page["project_#{project.id}_task_list_#{task_list.id}_edit_task_#{task.id}"].hide
  end
  
  def show_edit_task_form(project, task_list, task)
    page["project_#{project.id}_task_list_#{task_list.id}_edit_task_#{task.id}"].show
  end

  def remove_edit_task_form(project, task_list, task)
    page["project_#{project.id}_task_list_#{task_list.id}_edit_task_#{task.id}"].remove
  end


  def edit_task_form(project, task_list, task)
    render :partial => 'tasks/edit', :locals => {
      :project => project,
      :task_list => task_list,
      :task => task }
  end

  def show_edit_task(project, task_list, task)
    update_page do |page|
      page.show_edit_task_form(project,task_list,task)
      page.hide_task(project,task_list,task)
    end
  end

  def hide_edit_task(project, task_list, task)
    update_page do |page|
      page.hide_edit_task_form(project,task_list,task)
      page.show_task(project,task_list,task)
    end    
  end

  def edit_task(element,action,project,task_list)
    if action == :show
      page["project_#{project.id}_task_list_#{task_list.id}_edit_task_#{element.to_s}"].show
    elsif action == :hide
      page["project_#{project.id}_task_list_#{task_list.id}_edit_task_#{element.to_s}"].hide
    elsif element == :form
      if action == :reset
        page << "Form.reset('project_#{project.id}_task_list_#{task_list.id}_edit_task_form')"
      elsif action == :focus
        page << "$('project_#{project.id}_task_list_#{task_list.id}_edit_task_form').auto_focus()"
      end
    end
  end

end