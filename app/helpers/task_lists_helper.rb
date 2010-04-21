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

  def task_list_id(element,project,task_list=nil)
    task_list ||= project.task_lists.new
    js_id(element,project,task_list)
  end

  def task_list_link(project,task_list=nil)
    task_list ||= project.task_lists.new
    unobtrusive_app_link(project,task_list)
  end
  
  def task_list_index_header(project,task_list)
    render :partial => 'task_lists/header_index', :locals => {:project => project, :task_list => task_list}
  end

  def task_list_form_for(project,task_list,&proc)
    unobtrusive_app_form_for(project,task_list,&proc)
  end

  def task_list_submit(project,task_list)
    unobtrusive_app_submit(project,task_list)
  end
  
  # Jenny helpers
  
  def hide_task_list(project,task_list)
    unobtrusive_app_toggle(project,task_list)
  end

  def show_task_list(project,task_list)
    unobtrusive_app_toggle(project,task_list)
  end
  
  def show_new_task_list(project,task_list=nil)
    task_list ||= project.task_lists.new
    unobtrusive_app_toggle(project,task_list)
  end
  
  #

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
    content = render(:partial => 'task_lists/task_list',
      :locals => {
        :project => project,
        :task_list => task_list,
        :sub_action => sub_action })
    
    list_id = task_list_id(nil,project,task_list)
    page.call "TaskList.insertList", list_id, content, (task_list.archived || false)
  end
  
  def remove_task_list(list_id)
    page.call "TaskList.removeList", list_id
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
    link_to h(task_list.name), project_task_list_path(task_list.project,task_list), :id => task_list_id(:title, task_list.project, task_list)
  end

  def task_list_action_links(project,task_list)
    render :partial => 'task_lists/actions',
    :locals => {
      :project => project,
      :task_list => task_list }
  end

  def task_list_primer(project,hidden=false)
    return unless project.editable?(current_user)
    render :partial => 'task_lists/primer', :locals => { :project => project, :primer_hidden => hidden }
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
  
  def rename_task_list_link(project,task_list, on_index=false)
    link_to t('task_lists.actions.rename'), 
            '#', :class => 'taskListUpdate', 
            :action_url => edit_project_task_list_path(project, task_list, :part => 'title', :on_index => (on_index ? 1 : 0))
  end
  
  def set_date_task_list_link(project,task_list, on_index=false)
    return if task_list.archived
    link_to t('task_lists.actions.set_dates'),
            '#',
            :class => 'taskListUpdate',
            :action_url => edit_project_task_list_path(project, task_list, :part => 'date', :on_index => (on_index ? 1 : 0))
  end
  
  def task_list_date_edit(project,task_list)
    render :partial => 'task_lists/date_edit_form', :locals => {:project => project, :task_list => task_list}
  end
  
  def task_list_title_edit(project,task_list)
    render :partial => 'task_lists/title_edit_form', :locals => {:project => project, :task_list => task_list}
  end

  def delete_task_list_link(project,task_list, on_index=false)
    link_to t('common.delete'),
      '#',
      :action_url => project_task_list_path(project,task_list, :on_index => (on_index ? 1 : 0)),
      :aconfirm => t('confirm.delete_task_list'),
      :class => 'taskListDelete'
  end
  
  def resolve_archive_task_list_link(project,task_list, on_index=false)
    return if task_list.archived
    link_to t('task_lists.actions.resolve_and_archive'),
            '#', :class => 'taskListResolve',
            :aconfirm => t('task_lists.actions.confirm_resolve_and_archive'),
            :action_url => archive_project_task_list_path(project, task_list, :on_index => (on_index ? 1 : 0))
  end
  
  def archive_task_list_link(project,task_list, on_index=false)
    return if task_list.archived
    link_to t('task_lists.actions.archive'),
            '#', :class => 'taskListResolve',
            :aconfirm => t('task_lists.actions.confirm_resolve_and_archive'),
            :action_url => archive_project_task_list_path(project, task_list, :on_index => (on_index ? 1 : 0))
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
  
  def task_list_archive_box(project,task_list)
    render :partial => 'task_lists/archive_box', :locals => { :project => project, :task_list => task_list }
  end
  
  def reopen_task_list_button(project,task_list)
    link_to content_tag(:span,t("task_lists.link.unarchive")), '#',
      {:class => "unarchive_task_list_link",
      :id => js_id("unarchive_link",project,task_list),
      :action_url => unarchive_project_task_list_path(project,task_list)}
  end
  
  def options_for_task_lists(lists)
    lists.map {|list| [ list.name, list.id ]}
  end

end