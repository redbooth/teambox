# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def submit(name,path,id = nil)
    submit_id = "submit_#{id}" unless id.nil?
    render :partial => 'shared/submit', :locals => { 
      :name => name, 
      :path => path, 
      :submit_id => id }
  end
  
  def submit_to_function(name, code,submit_id,loading_id)
    render :partial => 'shared/submit_to_function', :locals => {
      :name => name, 
      :code => code, 
      :submit_id => submit_id, 
      :loading_id => loading_id }
  end
  
  def hot_flashes(flash)
    show_flash_bar = true
    if flash[:success]
      class_name = 'success'
      text = flash[:success]
    elsif flash[:error]
      class_name = 'error'
      text = flash[:error]
    elsif flash[:notice]
      class_name = 'notice'
      text = flash[:notice]
    else  
      show_flash_bar = false
    end
    "<div class='flash_box flash_#{class_name}'><div>#{text}</div></div>" if show_flash_bar
  end
  
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
  
  def javascripts
    render :partial => 'shared/javascripts'
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

  def loading_image(id)
    image_tag('loading.gif', :id => id, :class => 'loading', :style => 'display: none')
  end
  
  def loading(action,id=nil)
    if id.nil?
      image_tag('loading.gif', :id => "#{action}_loading", :class => 'loading', :style => 'display: none')
    else  
      image_tag('loading.gif', :id => "#{action}_loading_#{id}", :class => 'loading', :style => 'display: none')
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
      datetime.in_time_zone(current_user.time_zone).strftime("%I:%M %p")
    elsif datetime > 1.day.ago.beginning_of_day
      t 'date.yesterday'
    elsif datetime > Time.current.beginning_of_year
      datetime.in_time_zone(current_user.time_zone).strftime("%b %d")
    else
      datetime.in_time_zone(current_user.time_zone).strftime("%b %d %Y")
    end
    # datetime.in_time_zone(current_user.time_zone).strftime("%I:%M %p &mdash; %b %d %Y")
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
    image_tag('drag.png', :class => 'drag', :style => 'display: none')
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
  
  def help_link
    link_to t('.help'), "http://help.teambox.com/#{controller.controller_name}"
  end

  def parenthesize(text)
    '(' + text.to_s + ')'
  end
  
  def people_watching(object)
    content_tag :div, :class => :watching do
      if object.watchers.empty?
        html =  t('common.nobody_watching')
      else
        html =  t('common.people_watching')
        html << object.watchers.join(", ")
      end
    end
  end
  
  def to_sentence(array)
    array.to_sentence(:two_words_connector => " #{t('common.and')} ", :last_word_connector => " #{t('common.and')} ")
  end
  
  def js_id(locals=[])
    id = []
    locals.each do |m|
      unless m.nil?
        id << "#{m.class.to_s.underscore}_#{m.id}" unless m.new_record?
      end  
    end
    id.join('_')
  end

end