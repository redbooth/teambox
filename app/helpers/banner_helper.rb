module BannerHelper

  def gantt_chart(chart, days = 14)
    unless chart.process(1,days)
      content_tag :div,
        chart.to_html(20,0),
        :class => 'gantt banner_item',
        :id => 'gantt_banner',
        :style => "#{'display: none' unless current_gantt_view?(:gantt)}"
    else
      render 'shared/gantt_banner_primer'
    end
  end

  def upcoming_events(events)
    if events.any?
      render 'shared/upcoming_events', :events => events
    else
      render 'shared/upcoming_events_primer'
    end
  end

  def event_css(i)
    Date.today == (Date.today.monday + i.day) ? 'today' : ''
  end

  def event_task_link(task)
    link_name = truncate(h(task.name), :length => 20)
    link_name = if task.open? && task.assigned
      "#{link_name} (#{content_tag(:span,h(task.assigned.user.short_name))})".html_safe
    else
      link_name.html_safe
    end
    link_to link_name,
      project_task_path(task.project, task),
      :class => "task_status_#{task.status_name}"
  end

  def calendar_banner_link
    content_tag(:div, link_to(t('common.calendar'), "#", :id => 'show_calendar_link'),
      :id => 'tab_calendar', :class => "tab #{'active' if current_gantt_view?(:calendar)}")
  end

  def gantt_banner_link
    content_tag(:div, link_to(t('common.gantt_chart'), "#", :id => 'show_gantt_chart_link'),
      :id => 'tab_gantt', :class => "tab #{'active' if current_gantt_view?(:gantt)}")
  end

  def banner(events,chart)
    render 'shared/banner',
      :events => events,
      :chart => chart
  end
end