# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def current_user_tag
    %(<meta name='current-username' content='#{current_user.login}'/>)
  end

  def csrf_meta_tag
    if protect_against_forgery?
      out = %(<meta name="csrf-param" content="%s"/>\n)
      out << %(<meta name="csrf-token" content="%s"/>)
      out % [ Rack::Utils.escape_html(request_forgery_protection_token),
              Rack::Utils.escape_html(form_authenticity_token) ]
    end
  end

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

  def render_navigation(project=nil, projects=nil, recent_projects=nil)
    render_tabnav :project do
      add_tab({:html => {:id => 'projects_tab',
                         :class => 'nav_tab',
                         :li_class => 'nav_tab_container',
                         :li_end => projects_tab_list(current_user.projects.unarchived)}
              }) do |t|
        name = project ? truncate(h(project.name), :length => 30) : t('shared.navigation.all_projects')
        t.named "#{name} #{image_tag('triangle.png', :class => 'triangle')}"
        t.links_to(project ? project_path(project) : projects_path)
        t.highlights_on :controller => :projects, :action => :index
        t.highlights_on :controller => :projects, :action => :show
        t.tab_index = 100
      end

      if project.nil?
        add_tab do |t|
         t.named t('shared.project_navigation.all_task_lists')
         t.links_to task_lists_path
         t.highlights_on :controller => :task_lists, :action => :index
         t.tab_index = 110
        end

        add_tab do |t|
         t.named t('shared.project_navigation.gantt')
         t.links_to gantt_view_task_lists_path
         t.highlights_on :controller => :task_lists, :action => :gantt_view
         t.tab_index = 120
        end

        if time_tracking_enabled?
          add_tab do |t|
            t.named t('shared.project_navigation.time_tracking')
            t.links_to time_path
            t.highlights_on :controller => :hours, :action => :index
            t.tab_index = 130
          end
        end

        # If we're on the community version, we'll show only one organization
        if Teambox.config.community && Organization.last
          add_tab do |t|
           t.named t('shared.project_navigation.organization')
           t.links_to organization_path(Organization.last)
           t.highlights_on :controller => :organizations
           t.li_class = 'organizations'
           t.li_class = 'right_side'
           t.tab_index = 140
          end
        elsif !Teambox.config.community
          add_tab do |t|
           t.named t('shared.project_navigation.organizations')
           t.links_to organizations_path
           t.highlights_on :controller => :organizations
           t.li_class = 'organizations'
           t.li_class = 'right_side'
           t.tab_index = 140
          end
        end

      else
        add_tab do |t|
          t.named t('shared.project_navigation.conversations')
          t.links_to  project_conversations_path(project)
          t.highlights_on :controller => :conversations
          t.tab_index = 110
        end

        add_tab do |t|
          t.named t('shared.project_navigation.task_lists')
          t.links_to  project_task_lists_path(project)
          t.highlights_on :controller => :task_lists
          t.highlights_on :controller => :tasks
          t.tab_index = 120
        end

        page_tab = project.has_member?(current_user) ? {:id => 'pages_tab', :class => 'nav_tab', :li_class => 'nav_tab_container', :li_end => pages_tab_list(project, project.pages) } : {}

        add_tab(:html => page_tab) do |t|
          t.named "#{t('shared.project_navigation.pages')} #{image_tag('triangle.png', :class => 'triangle') if project.has_member?(current_user)}"
          t.links_to  project_pages_path(project)
          t.highlights_on :controller => :pages
          t.tab_index = 130
        end

        if time_tracking_enabled? and project.tracks_time
          add_tab do |t|
            t.named t('shared.project_navigation.time_tracking')
            t.links_to  project_time_path(project)
            t.highlights_on :controller => :hours
            t.tab_index = 140
          end
        end

        add_tab do |t|
          t.named t('shared.project_navigation.files')
          t.links_to  project_uploads_path(project)
          t.highlights_on :controller => :uploads
          t.tab_index = 150
        end

        add_tab do |t|
          t.named t('shared.project_navigation.people')
          t.links_to  project_people_path(project)
          t.highlights_on :controller => :people
          t.li_class = 'right_side'
          t.tab_index = 170
        end

        if project.admin?(current_user)
          add_tab do |t|
            t.named t('shared.project_navigation.project_settings')
            t.links_to  project_settings_path(project)
            t.highlights_on :controller => :projects, :action => :edit
            t.li_class = 'right_side'
            t.tab_index = 160
          end
        end
      end
    end

  end

  def project_navigation(project)
    render 'shared/project_navigation', :project => project
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
    "<div class='errors_for'>#{error}</div>"
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

  # collecting stats about Teambox installations
  def tracking_code
    if Teambox.config.tracking_enabled and Rails.env.production?
      fake_img = "http://teambox.com/logo.png/#{request.host}"
      %(<div style="background-image: url(#{fake_img})"></div>)
    end
  end

  def organization_link_colour
    "".tap do |html|
      html << '<style type="text/css">'
      html << "a { color: ##{@organization ? @organization.settings['colours']['links'] : ''};}"
      html << "a:hover { color: ##{@organization ? @organization.settings['colours']['link_hover'] : ''};}"
      html << "body { font-color: ##{@organization ? @organization.settings['colours']['text'] : ''};}"
      html << '</style>'
    end
  end

  def organization_header_bar_colour
    "background: ##{@organization ? @organization.settings['colours']['header_bar'] : ''};"
  end

  def custom_organization_colour_field(f, organization, field)
    colour = organization.settings['colours'][field]
    "".tap do |html|
      html << f.hidden_field(:settings, :id => "organization_settings_colours_#{field}", :name => "organization[settings][colours][#{field}]", :value => colour)
      html << content_tag('button', '', :id => "organization_settings_colours_#{field}_swatch", :class => 'colorbox', :style=>"width: 56px; height: 56px; border: 1px outset #666; cursor: crosshair;")
    end
  end
end
