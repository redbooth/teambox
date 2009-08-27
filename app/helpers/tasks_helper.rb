module TasksHelper
  def list_tasks(tasks)
    render :partial => 'tasks/task', :collection => tasks
  end
  
  def task_fields(f)
    render :partial => 'tasks/fields', :locals => { :f => f}
  end
end
