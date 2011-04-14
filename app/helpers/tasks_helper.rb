module TasksHelper

  def task_classes(task)
    [].tap do |classes|
      classes << 'due_today' if task.due_today?
      classes << 'due_tomorrow' if task.due_tomorrow?
      classes << 'due_week' if task.due_in?(1.weeks)
      classes << 'due_2weeks' if task.due_in?(2.weeks)
      classes << 'due_3weeks' if task.due_in?(3.weeks)
      classes << 'due_month' if task.due_in?(1.months)
      classes << 'overdue' if task.overdue?
      classes << 'unassigned_date' if task.due_on.nil?
      classes << "status_#{task.status_name}"
      classes << 'status_notopen' if !task.open?
      classes << 'due_on' unless task.due_on.nil? or task.closed?
      classes << (task.assigned.nil? ? 'unassigned' : 'assigned') unless task.closed?
      classes << "user_#{task.assigned.user_id}" unless task.assigned.nil?
    end.join(' ')
  end

  def sidebar_tasks(tasks)
    render :partial => 'tasks/task_sidebar',
      :as => :task,
      :collection => tasks#.sort { |a,b| (a.due_on || 1.year.from_now.to_date) <=> (b.due_on || 1.year.from_now.to_date) }
    # Because of the way this sort is implemented, it might be redundant
  end

  def render_due_on(task,user)
    content_tag(:span, due_on(task), :class => 'due_on')
  end

  def render_assignment(task,user)
    render 'tasks/assigned', :task => task, :user => user
  end
  
  def task_status_badge(name)
    content_tag(:span, localized_status_name(name), :class => "task_status task_status_#{name}")
  end

  def comment_task_status(comment)
    if comment.initial_status? or comment.status_transition?
      [].tap { |out|
        if comment.status_transition?
          out << task_status_badge(comment.previous_status_name)
          out << content_tag(:span, '&rarr;'.html_safe, :class => "arr status_arr")
        end
        out << task_status_badge(comment.status_name)
      }.join(' ').html_safe
    end
  end

  def comment_task_due_on(comment)
    if comment.due_on_change?
      [].tap { |out|
        if comment.due_on_transition?
          out << span_for_due_date(comment.previous_due_on)
          out << content_tag(:span, '&rarr;'.html_safe, :class => "arr due_on_arr")
        end
        out << span_for_due_date(comment.due_on)
      }.join(' ').html_safe
    end
  end

  def task_status(task,status_type)
    status_for_column = status_type == :column ? "task_status_#{task.status_name}" : "task_counter"
    out = %(<span data-task-id=#{task.id} class='task_status #{status_for_column}'>)
    out << case status_type
    when :column  then localized_status_name(task)
    when :content then task.comments_count.to_s
    when :header  then localized_status_name(task)
    end
    out << %(</span>)
    out.html_safe
  end

  def due_on(task)
    if task.overdue? && task.overdue <= 5
      t('tasks.overdue', :days => task.overdue)
    else
      task_due_on(task.due_on)
    end
  end
  
  def task_due_on(due_on)
    now = Time.current.to_date
    if due_on == now
      t('tasks.due_on.today')
    elsif due_on == now+1
      t('tasks.due_on.tomorrow')
    elsif due_on
      I18n.l(due_on, :format => '%b %d')
    else
      I18n.t('tasks.due_on.undefined')
    end
  end

  def list_tasks(task_list, tasks,editable=true)
    render tasks,
      :project => task_list && task_list.project,
      :task_list => task_list,
      :editable => editable
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

  def time_tracking_doc
    link_to(t('projects.fields.new.time_tracking_docs'), "http://help.teambox.com/faqs/advanced-features/time-tracking", :target => '_blank')
  end

  def date_picker(f, field, options = {})
    selected_date = f.object.send(field.to_sym) ? localize(f.object.send(field.to_sym), :format => :long) : ''

    content_tag :div, :class => "date_picker" do
      [ image_tag('/images/calendar_date_select/calendar.gif', :class => :calendar_date_select_popup_icon),
        content_tag(:span, selected_date.blank? ? t('date_picker.no_date_assigned') : selected_date, :class => 'localized_date'),
        f.hidden_field(field, :class => :datepicker)
      ].join.html_safe
    end
  end
  
  def value_for_assigned_to_select
    params[:assigned_to] == 'all' ? 'task' : (params[:assigned_to] || 'task')
  end

  protected

    def span_for_due_date(due_date)
      content_tag(:span, task_due_on(due_date),
        :class => "assigned_date")
    end
    
    def span_for_thread_due_date(task)
      content_tag(:span, due_on(task),
        :class => "assigned_date")
    end
end
