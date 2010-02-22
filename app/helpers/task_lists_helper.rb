module TaskListsHelper

  def task_list_range(task_list)
    start_on  = task_list.start_on.nil? ? task_list.start_on : nil
    finish_on = task_list.finish_on.nil? ? task_list.finish_on : nil

    return unless (start_on.nil? && finish_on.nil?) || (start_on == finish_on)
    out = [I18n.l(start_on, :format => '%b %d'),I18n.l(finish_on, :format => '%b %d')].join(" - ")
    content_tag(:span,out,:class => 'range')
  end

  def task_list_id(element,project,task_list=nil)
    task_list ||= project.task_lists.new
    js_id(element,project,task_list)
  end

  def task_list_link(project,task_list=nil)
    task_list ||= project.task_lists.new
    app_link(project,task_list)
  end

  def task_list_form_for(project,task_list,&proc)
    app_form_for(project,task_list,&proc)
  end

  def task_list_submit(project,task_list)
    app_submit(project,task_list)
  end

  def task_list_form_loading(action,project,task_list)
    app_form_loading(action,project,task_list)
  end

  def hide_task_list(project,task_list)
    app_toggle(project,task_list)
  end

  def show_task_list(project,task_list)
    app_toggle(project,task_list)
  end

  def task_list_fields(f,project,task_list)
    render :partial => 'task_lists/fields', :locals => {
      :f => f,
      :project => project,
      :task_list => task_list }
  end

  def task_list_editable?(task_list,user,sub_action)
    sub_action != 'archived' && task_list.editable?(user)
  end

  def assign_tasks(project,task_list,sub_action)
    if sub_action == 'mine'
      person = project.people.find_by_user_id(current_user.id)
      task_list.tasks.unarchived.find(:all, :conditions => { :assigned_id => person.id} )
    elsif sub_action == 'archived'
      task_list.tasks.archived
    elsif sub_action == 'all'
      task_list.tasks.unarchived
    elsif sub_action == 'all_with_archived'
      task_list.tasks
    end
  end

  def archived_task_lists(project,task_lists)
    render :partial => 'task_lists/archived_task_list_with_tasks',
      :as => :task_list,
      :collection => task_lists, :locals => { :project => project }
  end

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

  def insert_task_list(project,task_list,sub_action)
    page.insert_html :top, "task_lists",
      :partial => 'task_lists/task_list_with_tasks',
      :locals => {
        :project => project,
        :task_list => task_list,
        :sub_action => sub_action,
        :current_target => nil }
  end

  def render_task_list_with_tasks(project,task_list)
    render :partial => 'task_lists/show', :locals => { :project => project, :task_list => task_list }
  end

  def reorder_task_list_link(project,task_lists)
    link_to_remote content_tag(:span,t("task_lists.link.reorder")),
      :url => sortable_project_task_lists_path(project),
      :loading => reorder_button_loading,
      :method => :get,
      :html => {
        :class => "reorder_task_list_link",
        :id => 'reorder_link' }
  end

  def reorder_task_lists(project,task_lists)
    update_page do |page|
      page << "$$('.tasks').each(function(task){ task.hide(); })"
      page << "$$('.new_task_link').each(function(task){ task.hide(); })"
      page << "$$('.task_list_wrap').each(function(task_list){ task_list.addClassName('task_list_wrap_reorder');})"
    end
  end

  def tabular_task_lists(project,task_lists,sub_action)
    render :partial => 'task_lists/tabular_task_list',
    :collection => task_lists,
    :as => :task_list,
    :locals => {
      :project => project,
      :sub_action => sub_action }
  end

  def tabular_task_list(project,task_list,sub_action)
    render :partial => 'task_lists/tabular_task_list',
    :locals => {
      :project => project,
      :task_list => task_list,
      :sub_action =>  sub_action }
  end


  def task_list_column(project,task_lists,sub_action,current_target = nil)
    render :partial => 'task_lists/column', :locals => {
        :project => project,
        :task_lists => task_lists,
        :sub_action => sub_action,
        :current_target => current_target }
  end

  def list_task_lists(project,task_lists,sub_action,current_target=nil)
    render :partial => 'task_lists/task_list_with_tasks',
      :collection => task_lists, :as => :task_list,
      :locals => {
        :project => project,
        :sub_action => sub_action,
        :current_target => current_target }
  end

  def the_task_list_link(task_list)
    link_to h(task_list.name), project_task_list_path(task_list.project,task_list)
  end

  def task_list_action_links(project,task_list)
    render :partial => 'task_lists/actions',
    :locals => {
      :project => project,
      :task_list => task_list }
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

  def task_lists_sortable(project)
    update_page_tag do |page|
      page.sortable("sortable_task_lists",{
        :tag => 'div',
        :url => reorder_task_lists_path(project),
        :only => 'task_list',
        :format => page.literal('/task_list_(\d+)/'),
        :handle => 'img.drag',
        :constraint => 'vertical'
      })
    end
  end

  def task_list_primer(project)
    return unless project.editable?(current_user)
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
    page.select('.task').each do |e|
      e.removeClassName('active_new')
      e.removeClassName('active_open')
      e.removeClassName('active_hold')
      e.removeClassName('active_resolved')
      e.removeClassName('active_rejected')
    end
    page.select('.task_list').invoke('removeClassName','active_list')
    page[item_list_id].addClassName('active_list')
  end

  def list_sortable_task_lists(project,task_lists)
    render :partial => 'task_lists/sortable_task_list',
      :collection => task_lists,
      :as => :task_list,
      :locals => {
        :project => project }
  end

  def reorder_button_loading
    update_page do |page|
      page['reorder_link'].className = 'loading_button'
    end
  end

  def print_task_lists_link(project)
    content_tag(:div,
      link_to(t('common.print'), project_task_lists_path(project, :format => :print)),
      :class => :print)
  end

  def tasks_for_all_projects(tasks)
    render :partial => 'task_lists/tasks_for_all_projects', :locals => { :tasks => tasks }
  end

end