module TaskListsHelper

  def filter_task_lists(project=nil)
    render :partial => 'task_lists/filter', :locals => { :project => project }
  end
  
  def filter_assigned_dropdown(project=nil)
    options = ['Anybody',     'all'],
              ['My tasks',    'mine'],
              ['Unassigned',  'unassigned']
    if !project.nil?
      options += [['--------', 'divider']]
      options += project.users.
                  reject { |u| u == current_user }.
                  collect { |u| [u.name, "user_#{u.id}"] }
    end
    select(:filter, :assigned, options, :disabled => 'divider')
  end
  
  def filter_due_date_dropdown(project=nil)
    options = ['Anytime',           'all'],
              ['Late tasks',        'overdue'],
              ['No date assigned',  'unassigned_date'],
              ['--------',          'divider'],
              ['Today',             'due_today'],
              ['Tomorrow',          'due_tomorrow']
    
    select(:filter, :due_date, options, :disabled => 'divider')
  end

  def task_list_range(task_list)
    start_on  = task_list.try(:start_on)
    finish_on = task_list.try(:finish_on)

    return nil unless start_on == finish_on
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

  def task_list_editable?(task_list,user)
    task_list.editable?(user)
  end

  def date_range_for_task_list(task_list)
    dates = [task_list.start_on, task_list.finish_on]
    if dates[0].nil? && dates[1].nil?
      "No dates assigned"
    elsif dates[0] && dates[1].nil?
      "Starts on #{date_for_task_list(dates[0])}"
    elsif dates[0].nil? && dates[1]
      "Ends on #{date_for_task_list(dates[1])}"
    else
      "#{date_for_task_list(dates[0])} - #{date_for_task_list(dates[1])}"
    end
  end

  def date_for_task_list(date)
    I18n.l(date, :format => '%b %d')
  end

  def render_task_list(project,task_list)
    render :partial => 'task_lists/task_list', :locals => {
      :project => project,
      :task_list => task_list }
  end

  def task_list_form(project,task_list)
    render :partial => 'task_lists/form', :locals => {
      :project => project,
      :task_list => task_list }
  end

  def insert_task_list(project,task_list,sub_action)
    page.insert_html :top, "task_lists",
      :partial => 'task_lists/task_list',
      :locals => {
        :project => project,
        :task_list => task_list,
        :sub_action => sub_action }
  end

  def reorder_task_lists(project,task_lists)
    update_page do |page|
      page << "$$('.tasks').each(function(task){ task.hide(); })"
      page << "$$('.new_task_link').each(function(task){ task.hide(); })"
      page << "$$('.task_list_wrap').each(function(task_list){ task_list.addClassName('task_list_wrap_reorder');})"
    end
  end

  def render_task_lists(project,task_lists,sub_action)
    render :partial => 'task_lists/task_list',
      :collection => task_lists,
      :as => :task_list,
      :locals => {
        :project => project,
        :sub_action => sub_action }
  end

  def render_task_list(project,task_list,sub_action)
    render :partial => 'task_lists/task_list',
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

  def replace_task_list_header(project,task_list)
    page.replace task_list_id(:edit_header,project,task_list),
      :partial => 'task_lists/header',
      :locals => {
        :project => project,
        :task_list => task_list}
  end

  def delete_task_list_link(project,task_list)
    link_to t('common.delete'),
      project_task_list_path(project,task_list),
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

  def print_task_lists_link(project = nil)
    if project
      content_tag(:div,
        link_to(t('common.print'), project_task_lists_path(project, :format => :print)),
        :class => :print)
    else
      content_tag(:div,
        link_to(t('common.print'), task_lists_path(:format => :print)),
        :class => :print)
    end
  end

  def tasks_for_all_projects(tasks)
    render :partial => 'task_lists/tasks_for_all_projects', :locals => { :tasks => tasks }
  end

  def task_list_overview_box(task_list)
    render :partial => 'task_lists/overview_box', :locals => { :task_list => task_list }
  end

end