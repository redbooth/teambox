# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def current_user_tag
    %(<meta name='current-username' content='#{current_user.login}'/>)
  end

  def csrf_meta_tag
    if protect_against_forgery?
      %(<meta name="csrf-param" content="#{Rack::Utils.escape_html(request_forgery_protection_token)}"/>\n<meta name="csrf-token" content="#{Rack::Utils.escape_html(form_authenticity_token)}"/>)
    end
  end
  
  def logo_image
    logo = @organization ? @organization.logo(:top) : "header_logo_black.png"
    image_tag(logo, :alt => "Teambox")
  end

  def archived_project_strip(project)
    if project.try(:archived)
      render 'shared/strip', :project => project
    end
  end

  def submit_or_cancel(object, name, submit_id, loading_id)
    render 'shared/submit_or_cancel',
      :object => object,
      :name => name,
      :submit_id => submit_id,
      :loading_id => loading_id
  end

  # types: success, error, notice
  def show_flash
    flash.each do |type, message|
      unless message.blank?
        haml_tag :p, message, :class => "flash flash-#{type}"
      end
    end
  end

  def navigation(project,projects,recent_projects)
    render 'shared/navigation',
      :project => project,
      :projects => projects,
      :recent_projects => recent_projects
  end

  def search_bar
    render 'shared/search_bar'
  end

  def header
    render 'shared/header'
  end

  def footer
    render 'shared/footer'
  end

  def javascripts
    render 'shared/javascripts'
  end

  def location_name?(names)
    Array(names).any?{ |name| name == location_name }
  end

  def location_name
    "#{action_name}_#{controller.controller_name}"
  end

  def loading_image(id)
    image_tag('loading.gif', :id => id, :class => 'loading', :style => 'display: none')
  end

  def loading(action, id = nil)
    img_id = id ? "#{action}_loading_#{id}" : "#{action}_loading"
    image_tag('loading.gif', :id => img_id, :class => 'loading', :style => 'display: none', :alt => '')
  end

  def posted_date(datetime)
    datetime = datetime.in_time_zone(current_user.time_zone) if current_user

    content_tag(:span, l(datetime, :format => :long), :id => "date_#{datetime.to_i}",
      :class => 'timeago', :alt => (datetime.to_i * 1000))
  end
  
  def datetime_ms(datetime)
    datetime = datetime.in_time_zone(current_user.time_zone)
    datetime.to_i * 1000
  end

  def drag_image
    image_tag('drag.png', :class => 'drag')
  end

  def loading_action_image(e=nil, hidden=false)
    image_tag('loading.gif',
              :id => "loading_action#{ "_#{e}" if e}",
              :class => 'loading_action',
              :style => (hidden ? 'display:none' : nil))
  end

  def is_controller?(_controller, _action = nil)
    controller.controller_name == _controller.to_s and (_action == nil or controller.action_name == _action.to_s)
  end

  def support_link
    if url = Teambox.config.support_url
      link_to t('.support'), url
    end
  end

  def mobile_link
    link_to t('.mobile'), change_format_path(:m)
  end

  def help_link
    if url = Teambox.config.help_url
      link_to t('.help'), "#{url}/#{controller.controller_name}"
    end
  end

  def to_sentence(array)
    array.to_sentence(:two_words_connector => " #{t('common.and')} ",
                      :last_word_connector => " #{t('common.and')} ")
  end

  def watch_link(project,user,target,js=true)
    unless %w[Task TaskList Conversation].include?(target.class.to_s)
      raise ArgumentError, "Invalid Model, was expecting Task, TaskList or Conversation but got #{target.class}"
    end
    target_name   = target.class.to_s.tableize
    task_list_url = target.is_a?(Task) ? "task_lists/#{target.task_list.id}/" : ''
    watch_status  = target.watching?(user) ? 'unwatch' : 'watch'
    
    # Bail if assigned
    return "" if target.is_a?(Task) && user.in_project(project).id == target.assigned_id

    url = "/projects/#{project.permalink}/#{task_list_url}#{target_name}/#{target.id}/#{watch_status}"

    if js
      link_to_remote "<span>#{t(".#{watch_status}")}</span>",
        :url => url, :html => { :id => 'watch_link', :class => 'button' }
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
      :style_settings => style_settings }
  end

  def upgrade_browser
    render 'shared/upgrade_browser'
  end

  def latest_announcement
    render 'shared/latest_announcement'
  end

  def errors_for(model, field)
    error = case errors = model.errors.on(field)
    when Array then errors.first
    when String then errors
    end
    "<div class='errors_for'>#{error}</div>"
  end

  def link_to_public_page(name)
    if url = Teambox.config["#{name}_url"]
      link_to t("shared.public_navigation.#{name}"), url
    end
  end

  def formatting_documentation_link
    link_to t('projects.show.text_styling'), text_styles_path, :rel => :facebox
  end
  
  def formatting_invitations_link
    link_to t('invitations.search.help'), invite_format_path, :rel => :facebox
  end

  def host_with_protocol
    request.protocol + request.host + request.port_string
  end
  
  def friendly_hours_value(hours)
    hours = hours.to_f
    if hours > 0
      minutes = (hours % 1) * 60
      if minutes.zero?
        t('comments.comment.hours', :hours => hours.to_i)
      else
        t('comments.comment.hours_with_minutes', :hours => hours.to_i, :minutes => minutes.to_i)
      end
    end
  end
  
  def set_reload_url(path)
    @reload_url = path
  end
  
  def reload_url
    @reload_url || url_for(request.path_parameters)
  end

  def rss?
    request.format == :rss
  end
  
  def time_tracking_enabled?
    APP_CONFIG['allow_time_tracking'] || false
  end
  
  def tooltip(text)
    haml_tag :p, h(text), :class => 'fyi', :style => 'display: none'
  end

  def auto_discovery_link_by_context(user, project)
    if user
      path = project ? project_path(project, :format => :rss) : projects_path(:format => :rss)
      auto_discovery_link_tag(:rss, user_rss_token(path))
    end
  end
  
  def configure_this_organization
    if Teambox.config.community && @community_role == :admin && @community_organization.description.blank? && params[:organization].nil?
      message = if location_name != "edit_organizations"
        link_to("Click here", organization_path(@community_organization)) + " to configure your organization"
      else
        "Introduce some HTML code for your main site to configure your site"
      end
      %(<div style="background-color: rgb(255,255,220); border-bottom: 1px solid rgb(200,200,150); width: 100%; display: block; font-size: 12px; padding: 10px 0; text-align: center">
        #{message}
      </div>)
    end
  end
  
  def locale_select_values
    I18n.available_locales.map { |code|
      [t(code, :scope => :locales, :locale => code), code.to_s]
    }.sort_by(&:first)
  end
end