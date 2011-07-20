# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def content_for(*args)
    super unless args.first.to_sym == :column and mobile?
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
        haml_tag :p, h(message), :class => "flash flash-#{type}"
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
    
    content_tag :time, localize(datetime, :format => :long), :class => 'timeago',
      :datetime => datetime.xmlschema, :pubdate => true, :'data-msec' => datetime_ms(datetime)
  end
  
  def datetime_ms(datetime)
    datetime = datetime.in_time_zone(current_user.time_zone) if current_user
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

  def upgrade_browser
    render 'shared/upgrade_browser'
  end
  
  def chrome_frame
    render 'shared/chrome_frame'
  end

  def latest_announcement
    render 'shared/latest_announcement'
  end

  def errors_for(model, field)
    error = case errors = model.errors.on(field)
    when Array then errors.first
    when String then errors
    end
    "<div class='errors_for'>#{error}</div>".html_safe
  end

  def formatting_documentation_link
    link_to '', text_styles_path, :rel => :facebox, :class => :style_icon, :title => t('projects.show.text_styling')
  end
  
  def formatting_invitations_link
    link_to t('invitations.search.help'), invite_format_path, :rel => :facebox
  end

  def host_with_protocol
    request.protocol + request.host + request.port_string
  end
  
  def human_hours(hours)
    hours = (hours.to_f * 100).round.to_f / 100
    if hours > 0
      minutes = ((hours % 1) * 60).round
      
      if minutes == 60
        hours += 1
        minutes = 0
      end
      
      if minutes.zero?
        t('comments.comment.hours', :hours => hours.to_i)
      else
        t('comments.comment.hours_with_minutes', :hours => hours.to_i, :minutes => minutes)
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
    Teambox.config.allow_time_tracking || false
  end
  
  def auto_discovery_link_by_context(user, project)
    if user
      path = project ? project_path(project, :format => :rss) : projects_path(:format => :rss)
      auto_discovery_link_tag(:rss, user_rss_token(path))
    end
  end
  
  def configure_this_organization
    if Teambox.config.community && @community_role == :admin && @community_organization.description.blank? && params[:organization].nil?
      message = if location_name != "appearance_organizations"
        link_to("Click here", appearance_organization_path(@community_organization)) + " to configure your organization"
      else
        "Introduce some HTML code for your main site to configure your site"
      end
      %(<div style="background-color: rgb(255,255,220); border-bottom: 1px solid rgb(200,200,150); width: 100%; display: block; font-size: 12px; padding: 10px 0; text-align: center">
        #{message}
      </div>).html_safe
    end
  end
  
  def locale_select_values
    I18n.available_locales.map { |code|
      [t(code, :scope => :locales, :locale => code), code.to_s]
    }.sort_by(&:first)
  end
  
  # collecting stats about Teambox installations
  def tracking_code
    if Teambox.config.tracking_enabled and Rails.env.production?
      fake_img = "http://teambox.com/logo.png/#{request.host}"
      %(<div style="background-image: url(#{fake_img})"></div>).html_safe
    end
  end

  def organization_link_colour
    "".tap do |html|
      html << '<style type="text/css">'
      html << "a { color: ##{@organization ? @organization.settings['colours']['links'] : ''};}"
      html << "a:hover { color: ##{@organization ? @organization.settings['colours']['link_hover'] : ''};}"
      html << "body { font-color: ##{@organization ? @organization.settings['colours']['text'] : ''};}"
      html << '</style>'
    end.html_safe
  end

  def organization_header_bar_colour
    "background: ##{@organization ? @organization.settings['colours']['header_bar'] : ''};"
  end

  def custom_organization_colour_field(f, organization, field)
    colour = organization.settings['colours'][field]
    "".tap do |html|
      html << f.hidden_field(:settings, :id => "organization_settings_colours_#{field}", :'data-default-color' => Organization.default_settings['colours'][field].upcase, :name => "organization[settings][colours][#{field}]", :value => colour)
      html << content_tag('button', '', :id => "organization_settings_colours_#{field}_swatch", :class => 'colorbox')
    end.html_safe
  end

  def preview_button
    content_tag(:button, :'data-alternate' => t('comments.preview.close'), :class => :preview) do
      t('comments.preview.preview')
    end
  end

  def upload_form_html_options(page, upload)
    id = upload.new_record? ? 'new_upload' : 'upload_file_form'
    form_classes = %w(upload_form app_form) 
    form_classes << 'form_error' unless upload.errors.empty?
    form_classes << 'new_upload' if upload.new_record?

    hidden = page || (action_name == 'index' && upload.errors.empty?)
    form_style = hidden ? 'display: none' : nil

    {:html => { :multipart => true, :id => id, :style => form_style, :class => form_classes}}
  end
  
  ##
  ##  eg. js_id(:edit_header,@project,@tasklist) => project_21_task_list_12_edit_header
  ##  eg. js_id(:new_header,@project,Task.new) => project_21_task_list_new_header
  ##  eg. js_id(@project,Task.new) => project_21_task_list
  def js_id(*args)
    if args.is_a?(Array)
      element = args[0].is_a?(String) || args[0].is_a?(Symbol) ? args[0] : nil
      models = args.slice(1,args.size-1)
      raise ArgumentError unless models.all?{|a|a.is_a?(ActiveRecord::Base)}
    elsif args.is_a?(ActiveRecord::Base)
      models = [args]
    else
      raise ArgumentError
    end
    generate_js_path(element,models)
  end

  def generate_js_path(element,models)
    path = []
    models.each do |model|
      path << model.class.to_s.underscore
      path << model.id unless model.new_record?
    end
    path << element unless element.nil?
    path.join('_')
  end

  def show_form_errors(target,form_id)
    page.select("##{form_id} .error").each do |e|
      e.remove
    end
    target.errors.each do |field,message|
    errors = <<BLOCK
      var e = $('#{form_id}').down('.#{field}');
      if (e) {
      if(e.down('.error'))
        e.down('.error').insert({bottom: "<br /><span>'#{message}'</span>"})
      else
        e.insert({ bottom: "<p class='error'><span>#{message}</span></p>"})
      }
BLOCK
      page << errors
    end
  end
end
