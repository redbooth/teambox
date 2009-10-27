module Task::EditHelper

  def replace_task(project,task_list,task)
    page.replace task_id(:single,:item,project,task_list,task),
      :partial => 'tasks/task', 
      :locals => { 
        :project => project,
        :task_list => task_list,
        :task => task,
        :current_target => task }
  end

  def edit_task_link(project,task_list)
    link_to_function t('common.edit'), show_edit_task(project,task_list)
  end
  
  def edit_task_form(project,task_list,task)
    render :partial => 'tasks/edit', :locals => {
      :project => project,
      :task_list => task_list, 
      :task => task }
  end

  def hide_edit_task(project,task_list)
    update_page do |page|
      page.edit_task(:header,:show,project,task_list)
      page.edit_task(:form,:hide,project,task_list)
      page.edit_task(:form,:reset,project,task_list)
    end  
  end

  def show_edit_task(project,task_list)
    update_page do |page|
      page.edit_task(:header,:hide,project,task_list)
      page.edit_task(:form,:show,project,task_list)
      page.edit_task(:form,:reset,project,task_list)
      page.edit_task(:form,:focus,project,task_list)
    end  
  end

end