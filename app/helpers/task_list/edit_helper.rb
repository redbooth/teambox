module TaskList::EditHelper

  def show_edit_task_list(project,task_list,task)
    update_page do |page|
      page.show_edit_task_form(project,task_list,task)
      page.hide_task(project,task_list,task)
    end
  end

  def hide_edit_task_list(project,task_list,task)
    update_page do |page|
      page.hide_edit_task_form(project,task_list,task)
      page.show_task_list(project,task_list,task)
    end
  end

  def show_edit_task_list(project,task_list)
  end

end