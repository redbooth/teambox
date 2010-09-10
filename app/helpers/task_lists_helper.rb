module TaskListsHelper

  def filter_task_lists(project=nil)
    render 'task_lists/filter', :project => project
  end
  
  def filter_assigned_dropdown(project=nil)
    options = [t('task_lists.filter.anybody'),     'all'],
              [t('task_lists.filter.my_tasks'),    'mine'],
              [t('task_lists.filter.unassigned'),  'unassigned']
    user_list = project ? project.users.sort_by(&:name) : Person.users_from_projects(current_user.projects)
    if !user_list.nil?
      options += [['--------', 'divider']]
      options += user_list.
                  reject { |u| u == current_user }.
                  collect { |u| [u.name, "user_#{u.id}"] }
    end
    select(:filter, :assigned, options, :disabled => 'divider')
  end
  
  def filter_due_date_dropdown(project=nil)
    options = [t('task_lists.filter.anytime'),           'all'],
              [t('task_lists.filter.late_tasks'),        'overdue'],
              [t('task_lists.filter.no_date_assigned'),  'unassigned_date'],
              ['--------',          'divider'],
              [t('task_lists.filter.today'),             'due_today'],
              [t('task_lists.filter.tomorrow'),          'due_tomorrow'],
              [t('task_lists.filter.week'),              'due_week'],
              [t('task_lists.filter.2weeks'),            'due_2weeks'],
              [t('task_lists.filter.3weeks'),            'due_3weeks'],
              [t('task_lists.filter.month'),             'due_month']
    
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
    render 'task_lists/header_index', :project => project, :task_list => task_list
  end

  def task_list_form_for(project,task_list,&proc)
    unobtrusive_app_form_for(project,task_list,&proc)
  end

  def task_list_submit(project,task_list)
    unobtrusive_app_submit(project,task_list)
  end
  
  # Jenny helpers
  
  def new_task_list_url(project,task_list)
    new_project_task_list_path(project)
  end
  
  def edit_task_list_url(project,task_list)
    edit_project_task_list_path(project, task_list)
  end
  
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
    render 'task_lists/fields',
      :f => f,
      :project => project,
      :task_list => task_list
  end
  
  def task_list_title_fields(f,project,task_list)
    render 'task_lists/title_fields',
      :f => f,
      :project => project,
      :task_list => task_list
  end
  
  def task_list_date_fields(f,project,task_list)
    render 'task_lists/date_fields',
      :f => f,
      :project => project,
      :task_list => task_list
  end

  def task_list_editable?(task_list,user)
    task_list.editable?(user)
  end

  def date_range_for_task_list(task_list)
    dates = [task_list.start_on, task_list.finish_on]
    if dates[0].nil? && dates[1].nil?
      t('task_lists.index.no_dates_assigned')
    elsif dates[0] && dates[1].nil?
      t('task_lists.index.starts_on', :date => date_for_task_list(dates[0])) 
    elsif dates[0].nil? && dates[1]
      t('task_lists.index.ends_on', :date => date_for_task_list(dates[1])) 
    else
      "#{date_for_task_list(dates[0])} - #{date_for_task_list(dates[1])}"
    end
  end

  def date_for_task_list(date)
    I18n.l(date, :format => '%b %d')
  end

  def render_task_list(project,task_list)
    render 'task_lists/task_list',
      :project => project,
      :task_list => task_list
  end

  def task_list_form(project,task_list)
    render 'task_lists/form',
      :project => project,
      :task_list => task_list
  end

  def options_for_render_task_list(project,task_list)
    {:partial => 'task_lists/task_list',
      :locals => {
        :project => project,
        :task_list => task_list}}
  end
  
  def insert_task_list(project,task_list)
    content = render(options_for_render_task_list(project,task_list))
    list_id = task_list_id(nil,project,task_list)
    page.call "TaskList.insertList", list_id, content, (task_list.archived || false)
  end
  
  def replace_task_list(project,task_list)
    content = render(options_for_render_task_list(project,task_list))
    list_id = task_list_id(nil,project,task_list)
    page.call "TaskList.replaceList", list_id, content, task_list.archived
  end
  
  def remove_task_list(list_id)
    page.call "TaskList.removeList", list_id
  end

  def render_task_lists(project,task_lists)
    render :partial => 'task_lists/task_list',
      :collection => task_lists,
      :as => :task_list,
      :locals => {
        :project => project}
  end

  def render_task_list(project,task_list)
    render 'task_lists/task_list', :project => project, :task_list => task_list
  end

  def task_list_column(project,current_target = nil)
    render :partial => 'task_lists/column', :locals => {
        :project => project,
        :current_target => current_target }
  end

  def gantt_view_link(project=nil)
    if project
      link_to t('.gantt_view'), gantt_view_project_task_lists_path(project), :class => :gantt_link
    else
      link_to t('.gantt_view'), gantt_view_task_lists_path, :class => :gantt_link
    end
  end

  def the_task_list_link(task_list)
    link_to h(task_list.name), project_task_list_path(task_list.project,task_list), :id => task_list_id(:title, task_list.project, task_list)
  end

  def task_list_action_links(project,task_list)
    render 'task_lists/actions', :project => project, :task_list => task_list
  end

  def task_list_primer(project,hidden=false)
    if project.editable?(current_user)
      render 'task_lists/primer', :project => project, :primer_hidden => hidden
    end
  end

  def task_list_header(project,task_list)
    render 'task_lists/header', :project => project, :task_list => task_list
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
            edit_project_task_list_path(project, task_list, :part => 'title', :on_index => (on_index ? 1 : 0)),
            :class => 'taskListUpdate'
  end
  
  def set_date_task_list_link(project,task_list, on_index=false)
    return if task_list.archived
    link_to t('task_lists.actions.set_dates'),
            edit_project_task_list_path(project, task_list, :part => 'date', :on_index => (on_index ? 1 : 0)),
            :class => 'taskListUpdate'
  end
  
  def task_list_date_edit(project,task_list)
    render 'task_lists/date_edit_form', :project => project, :task_list => task_list
  end
  
  def task_list_title_edit(project,task_list)
    render 'task_lists/title_edit_form', :project => project, :task_list => task_list
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
    link_to t('task_lists.actions.archive'),
            '#', :class => 'taskListResolve',
            :aconfirm => t('task_lists.actions.confirm_resolve_and_archive'),
            :action_url => archive_project_task_list_path(project, task_list, :on_index => (on_index ? 1 : 0))
  end
  
  def show_archived_tasks_link(project,task_list)
    archived_tasks = task_list.tasks.archived.length
    link_to t('task_lists.actions.show_archived', :count => archived_tasks),
            project_task_lists_path(project, task_list),
            :class => 'show_archived_tasks_link'
  end

  def print_task_lists_link(project = nil)
    if project
      link_to t('common.print'), project_task_lists_path(project, :format => :print), :class => :print_link
    else
      link_to t('common.print'), task_lists_path(:format => :print), :class => :print_link
    end
  end

  def tasks_for_all_projects(tasks)
    render 'task_lists/tasks_for_all_projects', :tasks => tasks
  end

  def task_list_overview_box(task_list)
    render 'task_lists/overview_box', :task_list => task_list
  end
  
  def task_list_archive_box(project,task_list)
    render 'task_lists/archive_box', :project => project, :task_list => task_list
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

  GANTT_VIEW_SETTINGS = { :gantt => 0, :calendar => 1 }

  def current_gantt_view?(setting)
    current_gantt_view == GANTT_VIEW_SETTINGS[setting]
  end
      
  def current_gantt_view
    @current_gantt_view ||= GANTT_VIEW_SETTINGS[:gantt]
  end
  
  def current_gantt_view=(setting)
    session[:gantt_view] = GANTT_VIEW_SETTINGS[setting]
    @current_gantt_view = session[:gantt_view]
  end

end