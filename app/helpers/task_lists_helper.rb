module TaskListsHelper
  def list_task_lists(project)
    render :partial => 'task_lists/task_list', :collection => project.task_lists
  end
  
  def new_task_list_link(project)
    link_to t('.new_task_list_link'), new_project_task_list_path(project)
  end
  
  def task_list_fields(f)
    render :partial => 'task_lists/fields', :locals => { :f => f }
  end
  
  def task_list_link(task_list)
    link_to h(task_list.name), project_task_list_path(task_list.project,task_list)
  end
end
