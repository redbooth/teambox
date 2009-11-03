module TaskListsHelper
  def render_task_list(project,task_list,current_target)
    render :partial => 'task_lists/task_list', :locals => {
      :project => project,
      :task_list => task_list,
      :current_target => current_target }
  end

  def task_list_form(project,task_list)  
    render :partial => 'task_lists/form', :locals => {
      :project => project,
      :task_list => task_list }
  end

  def insert_task_list(project,task_list)  
    page.insert_html :top, "task_lists",
      :partial => 'task_lists/task_list_with_tasks', 
      :locals => {  
        :project => project, 
        :task_list => task_list,
        :current_target => nil }
  end

  def task_list_id(element,project,task_list=nil)
    if task_list.nil? or (task_list and task_list.new_record?)
      "#{js_id([project,task_list])}_task_list_#{"#{element}" unless element.nil?}"
    else  
      "#{js_id([project,task_list])}_#{"#{element}" unless element.nil?}"
    end
  end

  def task_list_form_for(project,task_list,&proc)
    raise ArgumentError, "Missing block" unless block_given?
    action = task_list.new_record? ? 'new' : 'edit'

    remote_form_for([project,task_list],
      :loading => task_list_form_loading(action,project,task_list),
      :html => {
        :id => task_list_id("#{action}_form",project,task_list),
        :class => 'task_form',
        :style => 'display: none'},
        &proc)
  end

  def render_task_list_with_tasks(project,task_list)
    render :partial => 'task_lists/show', :locals => { :project => project, :task_list => task_list }
  end
  
  def task_list_submit(project,task_list)
    action = task_list.new_record? ? 'new' : 'edit'
    submit_id = task_list_id("#{action}_submit", project,task_list)
    loading_id = task_list_id("#{action}_loading",project,task_list)
    submit_to_function t("task_lists.#{action}.submit"), hide_task_list(project,task_list), submit_id, loading_id
  end

  def task_list_form_loading(action,project,task_list)
    update_page do |page|
      submit_id  = task_list_id("#{action}_submit", project,task_list)
      loading_id = task_list_id("#{action}_loading",project,task_list)
      page[submit_id].hide
      page[loading_id].show
    end    
  end

  def hide_task_list(project,task_list)
    action = task_list.new_record? ? 'new' : 'edit'
    
    header_id = task_list_id("#{action}_header",project,task_list)
    link_id = task_list_id("#{action}_link",project,task_list)
    form_id = task_list_id("#{action}_form",project,task_list)
    
    update_page do |page|
      task_list.new_record? ? page[link_id].show : page[header_id].show
      page[form_id].hide
      page << "Form.reset('#{form_id}')"
    end  
  end
  
  def show_task_list(project,task_list)
    action = task_list.new_record? ? 'new' : 'edit'
    
    header_id = task_list_id("#{action}_header",project,task_list)
    link_id = task_list_id("#{action}_link",project,task_list)
    form_id = task_list_id("#{action}_form",project,task_list)
    
    update_page do |page|
      task_list.new_record? ? page[link_id].hide : page[header_id].hide
      page[form_id].show
      page << "Form.reset('#{form_id}')"
      page << "$('#{form_id}').auto_focus()"
    end
  end  
  
  def task_list_link(project,task_list)
    action = task_list.new_record? ? 'new' : 'edit'

    link_to_function content_tag(:span,t("task_lists.link.#{action}")), show_task_list(project,task_list),
      :class => "#{action}_task_list_link",
      :id => task_list_id("#{action}_link",project,task_list)
  end
  
  def list_main_task_list(project,task_lists)
    render :partial => 'task_lists/main_task_lists',
    :collection => task_lists,
    :locals => {
      :project => project }    
  end
  
  def task_list_column(project,task_lists,current_target = nil)
    render :partial => 'task_lists/column', :locals => {
        :project => project,
        :task_lists => task_lists,
        :current_target => current_target }
  end

  def list_task_lists(project,task_lists,current_target=nil)
    render :partial => 'task_lists/task_list_with_tasks',
      :collection => task_lists, :as => :task_list,
      :locals => {
        :project => project,
        :current_target => current_target }
  end

  def the_task_list_link(task_list)
    link_to h(task_list.name), project_task_list_path(task_list.project,task_list)
  end

  def task_list_action_links(project,task_list)
    if task_list.owner?(current_user)
      render :partial => 'task_lists/actions',
      :locals => { 
        :project => project,
        :task_list => task_list }
    end
  end

  def task_list_partial_action_links(project, task_list)
    if logged_in?
      if task_list.owner?(current_user)
        render :partial => 'task_lists/partial_actions',
        :locals => { 
          :project => project,
          :task_list => task_list }
      end
    end
  end
    
  def task_list_fields(f,project,task_list)
    render :partial => 'task_lists/fields', :locals => { :f => f }
  end

  def highlight_task_list(project, task_list)
    page["task_list_#{task_list.id}"].highlight
  end
      
  def task_list_sortable_tag(task_list)
    update_page_tag do |page|
      page.sortable("project_#{task_list.project.id}_task_list_#{task_list.id}",{
        :tag => 'div',
        :url => order_project_task_list_path(task_list.project,task_list),
        :only => 'task',
        :format => page.literal('/task_(\d+)/'),
        :handle => '.drag',
        :constraint => 'vertical'
      })
    end
  end
  
  def task_list_sortable(task_list,url)
    page.sortable("project_#{task_list.project.id}_task_list_#{task_list.id}",{
      :tag => 'div',
      :url => url,
      :only => 'task',
      :format => page.literal('/task_(\d+)/'),
      :handle => 'span.drag'
    })
  end
  
  def task_list_primer(project)
    render :partial => 'task_lists/primer', :locals => { :project => project }
  end  
  
  def task_list_header(project,task_list)
    render :partial => 'task_lists/header', :locals => {
      :project => project,
      :task_list => task_list } 
  end  
  
  def replace_task_list(project,task_list)
    page.replace task_list_id(:item,project,task_list),
      :partial => 'task_lists/task_list', 
      :locals => { 
        :project => project,
        :task_list => task_list,
        :current_target => task_list }
  end

  def replace_task_list_header(project,task_list)
    page.replace task_list_id(:edit_header,project,task_list),
      :partial => 'task_lists/header', 
      :locals => { 
        :project => project,
        :task_list => task_list}
  end  
  
  def delete_task_list_link(project,task_list)
    link_to_remote t('common.delete'), 
      :url => project_task_list_path(project,task_list),
      :loading => delete_task_list_loading(project,task_list),
      :confirm => t('confirm.delete_task_list'), 
      :method => :delete
  end

  def delete_task_list_loading(project,task_list)
    edit_actions_id = task_list_id('edit_actions',project,task_list)
    delete_loading_id = task_list_id('delete_loading',project,task_list)
    update_page do |page|
      page[edit_actions_id].hide
      page[delete_loading_id].show
    end  
  end

  def show_destroy_task_list_message(task_list)
    page.replace 'show_task_list', :partial => 'task_lists/destroy_message', :locals => {
      :task_list => task_list }
  end

  def update_active_task_list(project,task_list)    
    page.replace_html 'content', :partial => 'task_lists/show', 
      :locals => { 
        :project => project,
        :task_list => task_list }

    item_list_id = task_list_id(:item,project,task_list)
    page.select('.task').invoke('removeClassName','active_task')
    page.select('.task_list').invoke('removeClassName','active_task_list')
    page[item_list_id].addClassName('active_task')
  end

end