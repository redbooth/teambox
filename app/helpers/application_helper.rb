# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def header
    render :partial => 'shared/header'
  end

  def project_navigation(project)
    render :partial => 'shared/project_navigation',
      :locals => { :project => project }
  end
  
  def navigation(project,recent_projects)
    render :partial => 'shared/navigation',
      :locals => { 
        :project => project, 
        :recent_projects => recent_projects }
  end

  def global_navigation
    render :partial => 'shared/global_navigation'
  end
  
  def footer
    render :partial => 'shared/footer'
  end

  def location_name?(names)
    names.any?{ |name| name == location_name }
  end
    
  def location_name
    "#{action_name}_#{controller.controller_name}"
  end
   
  def ef(e)
    page << "if($('#{e}')){"
  end

  def esf(e)
    page << "}else if($('#{e}')){"
  end

  def els
    page << "}else{"
  end

  def en
    page << "}"
  end

  def loading(action,id=nil)
    if id.nil?
      image_tag('loading.gif', :id => "#{action}_loading", :style => 'display: none')
    else  
      image_tag('loading.gif', :id => "#{action}_loading_#{id}", :style => 'display: none')
    end
  end
  
  def show_loading(action,id=nil)
    update_page do |page|
      if id.nil?
        page["#{action}_loading"].show
        page.ef("#{action}_link")
          page["#{action}_link"].hide
        page.en
      else
        page["#{action}_loading_#{id}"].show
        page.ef("#{action}_#{id}_link")
          page["#{action}_#{id}_link"].hide
        page.en
      end
    end
  end
  
  def hide_loading(action,id=nil)
    update_page do |page|
      if id.nil?
        page["#{action}_loading"].hide
        page.ef("#{action}_link")
          page["#{action}_link"].hide
        page.en
      else
        page["#{action}_loading_#{id}"].hide
        page.ef("#{action}_#{id}_link")
          page["#{action}_#{id}_link"].show
        page.en
      end
    end
  end
  
  def posted_date(datetime)
    if datetime > Time.current.beginning_of_day
      datetime.strftime("%I:%M %p")
    elsif datetime > 1.day.ago.beginning_of_day
      t 'date.yesterday'
    elsif datetime > 7.days.ago
      datetime.strftime("%b %d")
    else
      datetime.strftime("%b %d %Y")
    end
    # datetime.strftime("%I:%M %p &mdash; %b %d %Y")
  end
  
  def trash_image
    image_tag('trash.jpg', :class => 'trash')
  end

  def pencil_image
    image_tag('pencil.jpg', :class => 'pencil')
  end

  def time_image
    image_tag('time.jpg', :class => 'time')
  end
    
  def hour_image
    image_tag('hours.jpg', :class => 'hour')
  end
  
  def drag_image
    image_tag('drag.jpg', :class => 'drag')
  end

  def add_image
    image_tag('add_button.jpg', :class => 'add')
  end
  
  def loading_action_image(e=nil)
    image_tag('loading_action.gif', :id => "loading_action#{ "_#{e}" unless e.nil?}")
  end
  
  def reload_javascript_events
      page << "Event.addBehavior.reload()"
  end
  
  def show_comments_count(target)
    render :partial => 'shared/comments_count', :locals => { :target => target, :unread_count => CommentRead.user(current_user).unread_count(target) }
  end
  
  def is_controller?(_controller, _action = nil)
    controller.controller_name == _controller.to_s and (_action == nil or controller.action_name == _action.to_s)
  end
  
end