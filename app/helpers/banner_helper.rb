module BannerHelper

  def gantt_chart(chart, days = 14)
    unless chart.process(1,days)
      content_tag :div,
        chart.to_html(20,0),
        :class => 'gantt banner_item',
        :id => 'gantt_banner',
        :style => "#{'display: none' unless current_gantt_view?(:gantt)}"
    else
      render :partial => 'shared/gantt_banner_primer'
    end
  end

  def upcoming_events(events)
    unless events.empty?
      render :partial => 'shared/upcoming_events',
        :locals => {
          :events => events }
    else
      render :partial => 'shared/upcoming_events_primer'
    end
  end

  def event_css(i)
    event_css = Date.today == (Date.today.monday + i.day) ? 'today' : ''
  end

  def event_task_link(task)
    link_name = truncate(task.name, :length => 20)
    link_name << " (#{content_tag(:span,task.assigned.user.short_name)})" if task.open? && task.assigned
    link_to link_name,
      project_task_list_task_path(task.project,task.task_list,task),
      :class => "task_status_#{task.status_name}"
  end

  def calendar_banner_link
    link_to t('common.calendar'), "#", :id => 'show_calendar_link', :class => ('active' if current_gantt_view?(:calendar))
  end

  def gantt_banner_link
    link_to t('common.gantt_chart'), "#", :id => 'show_gantt_chart_link', :class => ('active' if current_gantt_view?(:gantt))
  end

  def banner(events,chart)
    render :partial => 'shared/banner', :locals => {
      :events => events,
      :chart => chart }
  end
end