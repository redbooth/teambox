module TasksHelper
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

end
