module BannerHelper

  def gantt_chart(chart)
    
    unless chart.process(1,32)
      content_tag :div,
        chart.to_html(30,0),
        :class => 'gantt banner_item',
        :id => 'gantt_banner',
        :style => "#{'display: none' unless current_banner?(:gantt)}"
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
    link_name = truncate(task.name, 20)
    link_name << " (#{content_tag(:span,task.assigned.user.short_name)})" if task.open?    
    link_to link_name,
      project_task_list_task_path(task.project,task.task_list,task),
      :class => "task_status_#{task.status_name}"
  end
  
  def calendar_banner_link
    link_to "Calendar", "#", :id => 'calendar_banner_link'
    # link_to_remote 'Calendar', 
    #   :url => '',
    #   :loading => calendar_banner_loading,
    #   :html => { :id => 'calendar_banner_link',
    #   :class => "#{'active' if current_banner?(:calendar)}" }
  end

  def gantt_banner_link
    link_to 'Gantt Chart', "#", :id => 'gantt_banner_link'
    # link_to_remote 'Gantt Chart', 
    #   :url => '',
    #   :loading => gantt_banner_loading,
    #   :html => { 
    #     :id => 'gantt_banner_link', 
    #     :class => "#{'active' if current_banner?(:gantt)}" }
  end
     
  def gantt_banner_loading
    update_page do |page|
      page.hide_banner_items
      page['gantt_banner'].show
      page['gantt_banner_link'].addClassName('active')
    end
  end  
  # 
  # def calendar_banner_loading
  #   update_page do |page|
  #     page.hide_banner_items
  #     page['upcoming_events_banner'].show
  #     page['calendar_banner_link'].addClassName('active')
  #   end
  # end  
  
  def hide_banner_items
    page.select('.banner_navigation a').invoke('removeClassName','active')
    page.select('.banner_item').invoke('hide')
  end   

  def banner(events,chart)
    render :partial => 'shared/banner', :locals => {
      :events => events,
      :chart => chart }
  end
end  