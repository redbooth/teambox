module TaskList::NewHelper

  def insert_task_list(project,task_list)  
    page.insert_html :bottom, "task_lists",
      :partial => 'task_lists/task_list', 
      :locals => {  
        :project => project, 
        :task_list => task_list,
        :current_target => nil }
  end
      
  def new_task_list_form(project,task_list)
    render :partial => 'task_lists/new', :locals => {
      :project => project,
      :task_list => TaskList.new }
  end  
  
  def new_form_loading(project,task_list)
    update_page do |page|
      page[task_id(:new_submit,project,task_list)].hide
      page["new_task_loading_#{task_list.id}"].show
    end  
  end
  

  def show_new_task_list
    update_page do |page|
      page.new_task_list(:link,:hide)
      page.new_task_list(:form,:show)
      page.new_task_list(:form,:reset)
      page.new_task_list(:form,:focus)
    end  
  end  

  def hide_new_task_list
    update_page do |page|
      page.new_task_list(:link,:show)
      page.new_task_list(:form,:hide)
      page.new_task_list(:form,:reset)
    end
  end
  
  def new_task_list(element,action)
    if action == :show
      page["new_task_list_#{element.to_s}"].show
    elsif action == :hide
      page["new_task_list_#{element.to_s}"].hide
    elsif element == :form
      if action == :reset
        page << "Form.reset('new_task_list_form')"
      elsif action == :focus
        page << "$('new_task_list_form').auto_focus()"
      end
    end
  end

end