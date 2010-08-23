module TasksHelper

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

  def my_tasks(tasks)
    if tasks.any?
      render 'tasks/my_tasks', :tasks => tasks
    end
  end

  def sidebar_tasks(tasks)
    render :partial => 'tasks/task_sidebar',
      :as => :task,
      :collection => tasks#.sort { |a,b| (a.due_on || 1.year.from_now.to_date) <=> (b.due_on || 1.year.from_now.to_date) }
    # Because of the way this sort is implemented, it might be redundant
  end

  def render_due_on(task,user)
    render 'tasks/due_on', :task => task, :user => user
  end

  def render_assignment(task,user)
    render 'tasks/assigned', :task => task, :user => user
  end

  def check_status_type(task,status_type)
    unless [:column,:content,:header].include?(status_type)
      raise ArgumentError, "Invalid Status type, was expecting :column, :content or :header but got #{status_type}"
    end
    case status_type
      when :column
        "column_task_status_#{task.id}"
      when :content
        "content_task_status_#{task.id}"
      when :header
        "header_task_status_#{task.id}"
    end
  end

  def comment_task_status(comment)
    if comment.status_transition?
      haml_tag :span, :class => "task_status task_status_#{comment.previous_status_name}" do
        haml_concat localized_status_name(comment.previous_status_name)
      end
      haml_tag :span, '&rarr;', :class => "arr status_arr"
      haml_tag :span, :class => "task_status task_status_#{comment.status_name}" do
        haml_concat localized_status_name(comment.status_name)
      end
    end
  end

  def task_status(task,status_type)
    id = check_status_type(task,status_type)
    out = "<span id='#{id}' class='task_status task_status_#{task.status_name}'>"
    out << case status_type
    when :column  then localized_status_name(task)
    when :content then task.comments_count.to_s
    when :header  then localized_status_name(task)
    end
    out << "</span>"
    out
  end

  def due_on(task)
    if task.overdue? && task.overdue <= 5
      t('tasks.overdue', :days => task.overdue)
    else
      I18n.l(task.due_on, :format => '%b %d')
    end
  end

  def list_tasks(task_list, tasks,editable=true)
    render tasks,
      :project => task_list && task_list.project,
      :task_list => task_list,
      :editable => editable
  end

  def task_fields(f,project,task_list,task)
    render 'tasks/fields',
      :f => f,
      :project => project,
      :task_list => task_list,
      :task => task
  end
  
  def insert_task_options(project,task_list,task,editable=true)
    {:partial => 'tasks/task',
    :locals => {
      :task => task,
      :project => project,
      :task_list => task_list,
      :current_target => nil,
      :editable => editable}}
  end

  def localized_status_name(task_or_status)
    task_or_status = task_or_status.status_name if task_or_status.respond_to? :status_name
    t("tasks.status.#{task_or_status}")
  end
  
  def task_statuses_for_select
    Task::STATUS_NAMES.each_with_index.map { |name, code|
      [localized_status_name(name), code]
    }
  end
  
  def people_from_project_for_select(project)
    people = project.people(:include => :user).to_a
    current_person = people.detect { |p| p.user_id == current_user.id }
    people.delete(current_person)
    
    options = [
      [t('comments.new.assigned_to_nobody'), nil],
      [current_user.name, current_person.id]
    ]
    options.concat people.map { |p| [p.name, p.id] }.compact.sort_by(&:first)
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
    render 'tasks/overview_box', :task => task
  end

  def time_tracking_doc
    link_to(t('projects.fields.new.time_tracking_docs'), "http://help.teambox.com/faqs/advanced-features/time-tracking", :target => '_blank')
  end

  def date_picker(f, field)
    content_tag(:div,
      f.calendar_date_select(field, {
        :popup => :force,
        :footer => false,
        :year_range => 2.years.ago..10.years.from_now,
        :time => false,
        :buttons => true }),
      :class => 'date_picker')
  end
  
  def embedded_date_picker(f, field)
    content_tag(:div,
      f.calendar_date_select(field, {
        :embedded => true,
        :footer => false,
        :year_range => 2.years.ago..10.years.from_now,
        :time => false,
        :buttons => true }),
      :class => 'date_picker')
  end
  
  def value_for_assigned_to_select
    value = params[:assigned_to] == 'all' ? 'task' : params[:assigned_to]
    value ||= 'task'
  end
end