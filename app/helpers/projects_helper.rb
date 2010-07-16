module ProjectsHelper

  def delete_project_link(project)
    link_to content_tag(:span,t('projects.fields.forever')), 
    project_path(project),
    :method => :delete,
    :class => 'button',
    :confirm => t('projects.fields.confirm_delete')
  end

  def archive_project_link(project)
    link_to_function content_tag(:span,t('projects.fields.archiving')), 
    "$('project_archived').value = 1; $('content').down('.edit_project').submit();",
    :class => 'button'
  end
  
  def project_column_navigation
    render :partial => 'shared/project_column_navigation'
  end

  def project_new_primer
    render :partial => 'projects/new_primer'    
  end

  def permalink_example(permalink)
    out = host_with_protocol + projects_path + '/'
    out << content_tag(:span, permalink, :id => 'handle', :class => 'good')
    content_tag(:div, out, :id => 'preview')
  end

  def watch_permalink_example
    javascript_tag "$('project_permalink').observe('keyup', function(e) { Project.valid_url(); })"    
  end

  def project_settings_navigation
    render :partial => 'shared/project_settings_navigation'
  end

  def list_users_statuses(users)
    render :partial => 'users/status', :collection => users, :as => :user
  end
  
  def list_projects(projects)
    if projects.any?
      render :partial => 'shared/projects', :locals => { :projects => projects }
    end
  end

  def list_archived_projects(projects)
    if projects.any?
      render(:partial => 'shared/archived_projects', :locals => { :projects => projects })
    end
  end
  
  def project_link(project)
    link_to h(project.name), project_path(project)
  end
  
  def new_project_link
    link_to content_tag(:span, t('.new_project')), new_project_path, :class => 'add_button', :id => 'new_project_link'
  end
  
  def projects_tab_list(projects)
    render :partial => "shared/projects_dropdown", :locals => {:projects => projects}
  end

  def project_fields(f,project,sub_action='new')
    render :partial => "projects/fields/#{sub_action}", 
      :locals => { 
        :f => f,
        :project => project }
  end
   
  def project_primer
    render :partial => 'projects/primer'
  end

  def instructions_for_feeds
    content_tag(:div,
      link_to(t('shared.instructions.subscribe_to_feeds'), feeds_path),
      :class => :subscribe)
  end

  def subscribe_to_all_projects_link
    content_tag(:div,
      link_to(t('.subscribe_to_all'), user_rss_token(projects_path(:format => :rss))),
      :class => :subscribe)
  end

  def subscribe_to_project_link(project)
    content_tag(:div,
      link_to(t('.subscribe_to_project', :project => project),
        user_rss_token(project_path(project, :format => :rss))),
      :class => :subscribe)
  end

  def instructions_for_calendars
    content_tag(:div,
      link_to(t('shared.instructions.subscribe_to_calendars'), calendars_path),
      :class => :calendars)
  end

  def instructions_for_email(project)
    sufix = ''
    case location_name
      when 'show_projects' #project@app.teambox.com
        email_help = t('shared.instructions.send_email_help_project', :email => "#{project.permalink}@#{Teambox.config.app_domain}")
      when 'show_tasks' #project+task+12@app.teambox.com
        email_help = t('shared.instructions.send_email_help_task', :email => "#{project.permalink}+task+#{@task.id}@#{Teambox.config.app_domain}")
      when 'index_conversations' #project+conversation@app.teambox.com
        email_help = t('shared.instructions.send_email_help_conversations', :email => "#{project.permalink}+conversation@#{Teambox.config.app_domain}")
        sufix = '_conversations'
      when 'show_conversations' #project+conversation+5@app.teambox.com
        email_help = t('shared.instructions.send_email_help_conversation', :email => "#{project.permalink}+conversation+#{@conversation.id}@#{Teambox.config.app_domain}")
    end

    if email_help
      content_tag(:div,
        link_to_function(t('shared.instructions.send_email' + sufix), "$('email_help').setStyle({ display: 'block'})") +
        content_tag(:span, {:id => 'email_help'}) do
          #link_to_function(t('common.close'), "$('email_help').setStyle({ display: 'none'})", :class => "closeThis") +
          '<a href="#" class="closeThis">' + t('common.close') + "</a>" +
          email_help
        end,
        {:class => :email})
    else
      content_tag(:div, '****: ' + location_name)
    end
  end

  def subscribe_to_all_calendars_link
    content_tag(:div,
      t('.subscribe_to_all') +
      link_to(t('shared.task_navigation.all_tasks'), user_rss_token(projects_path(:format => :ics))) +
      ' ' + t('common.or') + ' ' +
      link_to(t('shared.task_navigation.my_assigned_tasks'), user_rss_token(projects_path(:format => :ics), 'mine')),
      :class => :calendar_links)
  end

  def subscribe_to_calendar_link(project)
    content_tag(:div,
      t('.subscribe_to_project', :project => project) +
      link_to(t('shared.task_navigation.all_tasks'), user_rss_token(project_path(project, :format => :ics))) +
      ' ' + t('common.or') + ' ' +
      link_to(t('shared.task_navigation.my_assigned_tasks'), user_rss_token(project_path(project, :format => :ics), 'mine')),
      :class => :calendar_links)
  end
  
  def print_projects_link
    content_tag(:div,
      link_to(t('common.print'), projects_path(:format => :print)),
      :class => :print)
  end

  def print_project_link(project)
    content_tag(:div,
      link_to(t('common.print'), project_path(project,:format => :print)),
      :class => :print)
  end
  
  def quicklink_conversations(project)
    desc = t('shared.project_navigation.conversations')
    link_to image_tag('drop_conv.png',
                      :alt => desc,
                      :title => desc), 
                      project_conversations_path(project)
  end
  
  def quicklink_tasks(project)
    desc = t('shared.project_navigation.task_lists')
    link_to image_tag('drop_tasklist.png', 
                      :alt => desc,
                      :title => desc), 
                      project_task_lists_path(project)
  end

  def quicklink_pages(project)
    desc = t('shared.project_navigation.pages')
    link_to image_tag('drop_page.png',
                      :alt => desc,
                      :title => desc), 
                      project_pages_path(project)
  end

  def reset_autorefresh
    "clearInterval(autorefresh)"
  end

  def autorefresh(activities, project = nil)
    first_id = Array(activities).first.id
    
    ajax_request = if project
      remote_function(:url => project_show_new_path(project, first_id))
    else
      remote_function(:url => show_new_path(first_id))
    end

    interval = APP_CONFIG['autorefresh_interval']*1000

    "autorefresh = setInterval(\"#{ajax_request}\", #{interval})"
  end

  def options_for_owner(people)
    people.map {|person| [ person.name, person.user_id ]}
  end
  
  def options_for_projects(projects)
    projects.map {|project| [ project.name, project.id ]}
  end
  
  def options_for_owned_projects(user, projects)
    projects.reject{|p| p.user_id != user.id}.map {|p| [ p.name, p.id ]}
  end
end
