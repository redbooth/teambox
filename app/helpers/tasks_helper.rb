module TasksHelper

  def task_id(element,project,task_list,task=nil)
    task ||= project.tasks.build
    js_id(element,project,task_list,task)
  end

  def task_classes(task)
    classes = []
    classes << 'due_today' if task.due_today?
    classes << 'due_tomorrow' if task.due_tomorrow?
    classes << 'overdue' if task.overdue?
    classes << 'unassigned_date' if task.due_on.nil?
    classes << (task.assigned.nil? ? 'unassigned' : "user_#{task.assigned.user_id}")
    if task.open?
      classes << 'mine' if task.assigned_to?(current_user)
    end
    classes.join(' ')
  end

  def task_link(project,task_list,task=nil)
    task ||= project.tasks.build
    app_link(project,task_list,task)
  end

  def task_form_for(project,task_list,task,&proc)
    unobtrusive_app_form_for(project,task_list,task,&proc)
  end

  def task_submit(project,task_list,task)
    unobtrusive_app_submit(project,task_list,task)
  end

  def task_form_loading(action,project,task_list,task)
    app_form_loading(action,project,task_list,task)
  end

  def show_task(project,task_list,task)
    app_toggle(project,task_list,task)
  end

  def hide_task(project,task_list,task)
    app_toggle(project,task_list,task)
  end

  def replace_task_column(project,task_lists,sub_action,task)
    page.replace_html 'column', task_list_column(project,task_lists,sub_action,task)
  end

  def insert_archive_box(project,task)
    page.insert_html :after, 'new_comment',
      :partial => 'tasks/archive_box', :locals => {
      :project => project,
      :task_list => task.task_list,
      :task => task }
  end

  def reopen_task_button(project,task_list,task)
    link_to_remote content_tag(:span,t('.reopen')),
      :url => reopen_project_task_list_task_path(project,task_list,task),
      :method => :get,
      :loading => loading_reopen_task,
      :html => {
        :class => 'button',
        :id => 'reopen_task_button' }
  end

  def loading_reopen_task
    update_page do |page|
      page['reopen_task_button'].className = 'loading_button'
      page['reopen_task_button'].writeAttribute('onclick','')
    end
  end

  def unarchive_task_button(project,task_list,task)
    link_to_remote content_tag(:span,t('.unarchive')),
      :url => unarchive_project_task_list_task_path(project,task_list,task),
      :method => :put,
      :loading => loading_archive_task,
      :html => {
        :class => 'button',
        :id => 'archive_button' }
  end

  def task_archive_box(project,task_list,task)
    return unless task.editable?(current_user)
    if task.archived?
      render :partial => 'tasks/unarchive_box', :locals => {
        :project => project,
        :task_list => task_list,
        :task => task }
    end
  end

  def loading_archive_task
    update_page do |page|
      page['archive_button'].className = 'loading_button'
      page['archive_button'].writeAttribute('onclick','')
    end
  end

  def my_tasks(tasks)
    if tasks.any?
      render :partial => 'tasks/my_tasks', :locals => { :tasks => tasks }
    end
  end

  def sidebar_tasks(tasks)
    render :partial => 'tasks/task_sidebar',
      :as => :task,
      :collection => tasks#.sort { |a,b| (a.due_on || 1.year.from_now.to_date) <=> (b.due_on || 1.year.from_now.to_date) }
    # Because of the way this sort is implemented, it might be redundant
  end

  def show_destroy_task_message(task)
    page.replace 'show_task', :partial => 'tasks/destroy_message', :locals => {
      :task => task }
  end


  def task_form(project,task_list,task)
    return unless task.editable?(current_user)
    render :partial => 'tasks/form', :locals => {
      :project => project,
      :task_list => task_list,
      :task => task }
  end


  def task_header(project,task_list,task)
    render :partial => 'tasks/header', :locals => {
      :project => project,
      :task_list => task_list,
      :task => task }
  end

  def render_due_on(task,user)
    render :partial => 'tasks/due_on',
    :locals => {
      :task => task,
      :user => user }
  end

  def render_assignment(task,user)
    render :partial => 'tasks/assigned',
    :locals => {
      :task => task,
      :user => user }
  end


  def update_task(task)
    page.replace task_id(:item,task.project,task.task_list,task),
      :partial => 'tasks/task',
      :locals => {
        :project => task.project,
        :task_list => task.task_list,
        :current_target => task }
  end

  def update_task_assignment(task,user)
    page.replace 'assigned', render_assignment(task,user)
  end

  def update_task_status(task,status_type)
    id = check_status_type(task,status_type)
    page.replace id, task_status(task,status_type)
  end

  def check_status_type(task,status_type)
    unless [:column,:content,:header].include?(status_type)
      raise ArgumentError, "Invalid Status type, was expecting :column, :content or :header but got #{status_type}"
    end
    case status_type
      when :column
        id = "column_task_status_#{task.id}"
      when :content
        id = "content_task_status_#{task.id}"
      when :header
        id = "header_task_status_#{task.id}"
    end
  end

  def comment_task_status(comment)
    out = ''
    if comment.transition?
      out << "<span class='task_status task_status_#{comment.previous_status_name}'>"
      out << I18n.t('tasks.status.'+comment.previous_status_name) unless comment.previous_status_open? && comment.previous_assigned?
      out << comment.previous_assigned.user.short_name if comment.previous_status_open? && comment.previous_assigned?
      out << "</span>"
      out << "<span class='arr status_arr'>&rarr;</span>"
    end
    out << "<span class='task_status task_status_#{comment.status_name}'>"
    out << I18n.t('tasks.status.'+comment.status_name) unless comment.status_open? && comment.assigned?
    out << comment.assigned.user.short_name if comment.status_open? && comment.assigned?
    out << "</span>"
    out
  end

  def task_status(task,status_type)
    id = check_status_type(task,status_type)
    out = "<span id='#{id}' class='task_status task_status_#{task.status_name}'>"
    out << case status_type
    when :column  then localized_status_name(task)
    when :content then task.comments_count.to_s
    end
    out << "</span>"
    out
  end

  def delete_task_link(project,task_list,task)
    link_to_remote t('common.delete'),
      :url => project_task_list_task_path(project,task_list,task),
      :loading => delete_task_loading(project,task_list,task),
      :confirm => t('confirm.delete_task'),
      :method => :delete
  end

  def delete_task_loading(project,task_list,task)
    edit_actions_id = task_id('edit_actions',project,task_list,task)
    delete_loading_id = task_id('delete_loading',project,task_list,task)
    update_page do |page|
      page[edit_actions_id].hide
      page[delete_loading_id].show
    end
  end

  def task_action_links(project,task_list,task)
    render :partial => 'tasks/actions',
    :locals => {
      :project => project,
      :task_list => task_list,
      :task => task }
  end

  def task_list_drag_link(task_list)
    drag_image if task_list.owner?(current_user)
  end


  def task_drag_link(task)
    drag_image if task.editable?(current_user)
  end

  def due_on(task)
    if task.overdue? && task.overdue <= 5
      t('tasks.overdue', :days => task.overdue)
    else
      I18n.l(task.due_on, :format => '%b %d')
    end
  end

  def list_tasks(tasks)
    render :partial => 'tasks/task',
      :collection => tasks
  end

  def task_fields(f,project,task_list,task)
    render :partial => 'tasks/fields', :locals => {
      :f => f,
      :project => project,
      :task_list => task_list,
      :task => task }
  end

  def render_task(project,task_list,task,comment)
    render :partial => 'tasks/show',
      :locals => {
        :project => project,
        :task_list => task_list,
        :task => task,
        :comment => comment }
  end

  def update_active_task(project,task_list,task,comment)
    page.replace_html 'content', :partial => 'tasks/show',
      :locals => {
        :project => project,
        :task_list => task_list,
        :task => task,
        :comment => comment }

    item_id = task_id(:item,project,task_list,task)
    page.select('.task').each do |e|
      e.removeClassName('active_new')
      e.removeClassName('active_open')
      e.removeClassName('active_hold')
      e.removeClassName('active_resolved')
      e.removeClassName('active_rejected')
    end
    page.select('.task_list').invoke('removeClassName','active')
    page.select('.task_navigation .active').invoke('removeClassName','active')
    page[item_id].addClassName("active_#{task.status_name}")
  end

  def insert_task(project,task_list,task)
    page.insert_html :bottom, task_list_id(:with_main_tasks,project,task_list),
      :partial => 'tasks/task',
      :locals => {
        :task => task,
        :project => project,
        :task_list => task_list,
        :current_target => nil }
  end

  def replace_task(project,task_list,task)
    page.replace task_id(:item,project,task_list,task),
      :partial => 'tasks/task',
      :locals => {
        :project => project,
        :task_list => task_list,
        :task => task,
        :current_target => task }
  end

  def replace_task_header(project,task_list,task)
    page.replace task_id(:edit_header,project,task_list,task),
      :partial => 'tasks/header',
      :locals => {
        :project => project,
        :task_list => task_list,
        :task => task }
  end

  def localized_status_name(task)
    I18n.t('tasks.status.' + task.status_name)
  end

  def insert_task_form(project,task_list,task)
    page.insert_html :after,
      task_id(:edit_header,project,task_list,task),
      :partial => 'tasks/form', :locals => {
        :project => project,
        :task_list => task_list,
        :task => task }
  end

  def tasks_sortable(project,task_list)
    update_page_tag do |page|
      page.sortable(task_list_id(:the_tasks,project,task_list),{
        :tag => 'div',
        :url => project_reorder_tasks_path(project,task_list),
        :only => 'task',
        :format => page.literal('/task_(\d+)/'),
        :handle => 'img.drag',
        :constraint => 'vertical' })
    end
  end

  def task_overview_box(task)
    render :partial => 'tasks/overview_box', :locals => { :task => task }
  end

  def date_picker(f, field)
    content_tag(:div,
      f.calendar_date_select(field, {
        :popup => :force,
        :footer => false,
        :year_range => 2.years.ago..10.years.from_now,
        :time => false,
        :buttons => false }),
      :class => 'date_picker')
  end
end