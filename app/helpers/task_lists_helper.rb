module TaskListsHelper
  
  def task_list_column(project,task_lists,current_target = nil)
    render :partial => 'task_lists/column', :locals => {
        :project => project,
        :task_lists => task_lists,
        :current_target => current_target }
  end

  def list_task_lists(project,task_lists,current_target=nil)
    render :partial => 'task_lists/task_list', 
      :collection => task_lists,
      :locals => {
        :project => project,
        :current_target => current_target }
  end

  def task_list_link(task_list)
    link_to h(task_list.name), project_task_list_path(task_list.project,task_list)
  end

  def task_list_action_links(project,task_list)
    if logged_in?
      if task_list.owner?(current_user)
        render :partial => 'task_lists/actions',
        :locals => { 
          :project => project,
          :task_list => task_list }
      end
    end
  end
    
  def task_list_fields(f)
    render :partial => 'task_lists/fields', :locals => { :f => f }
  end


  def insert_task_list(project,task_list)  
    page.insert_html :bottom, "task_lists",
      :partial => 'task_lists/task_list', 
      :locals => {  
        :project => project, 
        :task_list => task_list,
        :current_target => nil }
  end

  def highlight_task_list(project,task_list)
    page["task_list_#{task_list.id}"].highlight
  end
  
end