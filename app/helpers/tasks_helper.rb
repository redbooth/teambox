module TasksHelper
  def list_tasks(project,task_list,tasks)
    render :partial => 'tasks/task', 
      :collection => tasks,:locals => {
        :project => project,
        :task_list => task_list }
  end
  
  def task_fields(f)
    render :partial => 'tasks/fields', :locals => { :f => f}
  end
end
