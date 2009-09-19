module TaskListsHelper

  def task_list_column(project,task_lists,task_list = nil)
    render :partial => 'task_lists/column', :locals => {
        :project => project,
        :task_lists => task_lists,
        :task_list => task_list }
  end
  
  def list_task_lists(project,task_lists,current_target=nil)
    render :partial => 'task_lists/task_list', 
      :collection => task_lists,
      :locals => {
        :project => project,
        :current_target => current_target }
  end
  
  def new_task_list_link(project)
    link_to add_image, new_project_task_list_path(project),
    :class => 'add_button'
  end
  
  def task_list_fields(f)
    render :partial => 'task_lists/fields', :locals => { :f => f }
  end
  
  def task_list_link(task_list)
    link_to h(task_list.name), project_task_list_path(task_list.project,task_list)
  end
  

end
