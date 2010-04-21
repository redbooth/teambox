# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def strip(project)
    if project && project.archived
      render :partial => 'shared/strip', :locals => { :project => project }
    end
  end

  def submit(name,path,id = nil)
    submit_id = "submit_#{id}" if id
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

  # this is the unobtrusive pair of the submit_to_function
  def submit_or_cancel(object, name, submit_id, loading_id)
    render :partial => 'shared/submit_or_cancel', :locals => {
      :object => object,
      :name => name,
      :submit_id => submit_id,
      :loading_id => loading_id }
  end

  # types: success, error, notice
  def show_flash
    flash.each do |type, message|
      haml_tag :div, :class => "flash-#{type}" do
        haml_tag :div, message
      end unless message.blank?
    end
  end

  def header
    render :partial => 'shared/header'
  end

  def project_navigation(project)
    render :partial => 'shared/project_navigation',
      :locals => { :project => project }
  end

  def navigation(project,projects,recent_projects)
    render :partial => 'shared/navigation',
      :locals => {
        :project => project,
        :projects => projects,
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
    Array(names).any?{ |name| name == location_name }
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
    if id
      image_tag('loading.gif', :id => "#{action}_loading_#{id}", :class => 'loading', :style => 'display: none')
    else
      image_tag('loading.gif', :id => "#{action}_loading", :class => 'loading', :style => 'display: none')
    end
  end

  def show_loading(action,id=nil)
    update_page do |page|
      if id
        page["#{action}_loading_#{id}"].show
        page.ef("#{action}_#{id}_link")
          page["#{action}_#{id}_link"].hide
        page.en
      else
        page["#{action}_loading"].show
        page.ef("#{action}_link")
          page["#{action}_link"].hide
        page.en
      end
    end
  end

  def hide_loading(action,id=nil)
    update_page do |page|
      if id
        page["#{action}_loading_#{id}"].hide
        page.ef("#{action}_#{id}_link")
          page["#{action}_#{id}_link"].show
        page.en
      else
        page["#{action}_loading"].hide
        page.ef("#{action}_link")
          page["#{action}_link"].hide
        page.en
      end
    end
  end

  def posted_date(datetime)
    datetime = datetime.in_time_zone(current_user.time_zone)

    content_tag(:span, l(datetime, :format => :long), :id => "date_#{datetime.to_i}",
      :class => 'timeago', :alt => (datetime.to_i * 1000)) << javascript_tag("format_posted_date_#{I18n.locale}()")
  end
  
  def datetime_ms(datetime)
    datetime = datetime.in_time_zone(current_user.time_zone)
    (datetime.to_i * 1000)
  end

  def large_trash_image
    image_tag('trash_large.png', :class => 'trash_large')
  end

  def large_pencil_image
    image_tag('pencil_large.png', :class => 'pencil_large')
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
    image_tag('drag.png', :class => 'drag')
  end

  def remove_image
    image_tag('remove.png', :class => 'remove')
  end

  def add_image
    image_tag('add_button.jpg', :class => 'add')
  end

  def loading_action_image(e=nil)
    image_tag('loading_action.gif', :id => "loading_action#{ "_#{e}" if e}")
  end

  def reload_javascript_events
    page << "Event.addBehavior.reload()"
  end
  
  def reload_page_sort
    page.call "Page.makeSortable"
  end
    
  def is_controller?(_controller, _action = nil)
    controller.controller_name == _controller.to_s and (_action == nil or controller.action_name == _action.to_s)
  end

  def support_link
    if APP_CONFIG.has_key? 'support_url'
      link_to t('.support'), APP_CONFIG['support_url']
    end
  end

  def mobile_link
    link_to t('.mobile'), activities_path(:format => :m)
  end

  def help_link
    if APP_CONFIG.has_key? 'help_url'
      link_to t('.help'), "#{APP_CONFIG['help_url']}/#{controller.controller_name}"
    end
  end

  def parenthesize(text)
    '(' + text.to_s + ')'
  end

  def to_sentence(array)
    array.to_sentence(:two_words_connector => " #{t('common.and')} ", :last_word_connector => " #{t('common.and')} ")
  end

  def watch_link(project,user,target,js=true)
    raise ArgumentError, "Invalid Model, was expecting Task, TaskList or Conversation but got #{target.class}" unless ['Task','TaskList','Conversation'].include?(target.class.to_s)
    target_name = target.class.to_s.tableize
    task_list_url = target.class.to_s == 'Task' ? "task_lists/#{target.task_list.id}/" : ''
    watch_status =  target.watching?(user) ? 'unwatch' : 'watch'
    
    # Bail if assigned
    if target.class == Task and user.in_project(project).id == target.assigned_id
      return ""
    end

    url = "/projects/#{project.permalink}/#{task_list_url}#{target_name}/#{target.id}/#{watch_status}"

    if js
      link_to_remote "<span>#{t(".#{watch_status}")}</span>", :url => url, :html => { :id => 'watch_link', :class => 'button' }
    else
      link_to "<span>#{t(".#{watch_status}")}</span>", url
    end
  end

  def people_watching(project,user,target,state = :normal)
      if target.is_a?(Task)
        style_settings = target.closed? ? 'display:none' : ''
      end

      render :partial => 'shared/watchers', :locals => {
        :project => project,
        :user => user,
        :target => target,
        :state => state,
        :style_settings => style_settings}
  end

  def update_watching(project,user,target,state = :normal)
    page.replace 'watching', people_watching(project,user,target,state)
    page.delay(2) do
      page['updated_watch_state'].visual_effect :fade, :duration => 2
    end
    
  end

  def upgrade_browser
    render :partial => 'shared/upgrade_browser'
  end

  def latest_announcement
    render :partial => 'shared/latest_announcement'
  end

  def errors_for(model, field)
    error = case errors = model.errors.on(field)
    when Array then errors.first
    when String then errors
    end
    "<div style='color:red;font-weight:bold'>#{error}</div>"
  end

  def link_to_public_page(name)
    if APP_CONFIG.has_key?("#{name}_url")
      link_to t("shared.public_navigation.#{name}"), APP_CONFIG["#{name}_url"]
    end
  end

  def formatting_documentation_link
    link_to t('.text_styling'), 'http://daringfireball.net/projects/markdown/', :target => '_blank'
  end

  def host_with_protocol
    request.protocol + request.host + request.port_string
  end
  
  def friendly_hours_value(hours)
    hours_i = hours.to_i
    if hours - hours_i > 0
      hours
    else
      hours_i
    end
  end
  
  def set_reload_url(path)
    @reload_url = path
  end
  
  def reload_url
    (@reload_url || url_for(request.path_parameters))
  end
  
  def safe_remove_element(*ids)
    Array(ids).each do |id|
      page << "if ($('#{id}')) $('#{id}').remove();"
    end
  end
  
  def groups_enabled?
    APP_CONFIG['allow_groups'] || false
  end
  
  def time_tracking_enabled?
    APP_CONFIG['allow_time_tracking'] || false
  end
end