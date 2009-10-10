module TaskListsHelper

  def new_task_list_form(project,task_list)
    render :partial => 'task_lists/new', :locals => {
      :project => project,
      :task_list => task_list }
  end

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
  
  def new_task_list_link
    link_to_function content_tag(:span, t('.new_task_list')), show_new_task_list,
      :class => 'button', :id => "new_task_list_link"
  end
  
  def show_new_task_list
    update_page do |page|
      #page.hide_new_task_list_link
      #page.show_new_task_list_form
      #page.reset_new_task_list_form
    end  
  end  

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
  
  def reset_new_task_list_form(project,task_list)
    page << "Form.reset('new_task_list')"
  end
  
  def hide_new_task_list_link
    page["new_task_link"].hide
  end

  def show_new_task_list_link
    page["new_task_link"].show
  end
    
  def task_list_fields(f)
    render :partial => 'task_lists/fields', :locals => { :f => f }
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

  def show_edit_task_list(project,task_list)
  end
    
end
