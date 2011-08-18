module ProjectsHelper

  extend ActiveSupport::Memoizable

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
  
  def permalink_example(permalink)
    out = host_with_protocol + projects_path + '/'
    out << content_tag(:span, permalink, :id => 'handle', :class => 'good')
    content_tag(:div, out.html_safe, :id => 'preview')
  end

  def watch_permalink_example
    javascript_tag "$('project_permalink').observe('keyup', function(e) { Project.valid_url(); })"    
  end

  def list_users_statuses(users)
    render :partial => 'users/status', :collection => users, :as => :user
  end
  
  def new_project_link
    if !Teambox.config.community || (@community_organization && !@community_role.nil?)
      link_to content_tag(:span, t('.new_project')), new_project_path,
        :class => 'add_button', :id => 'new_project_link'
    end
  end
  
  def project_fields(f,project,sub_action='new')
    render "projects/fields/#{sub_action}",  :f => f, :project => project
  end
   
  def instructions_for_feeds
    link_to t('shared.instructions.subscribe_to_feeds'), feeds_path, :class => :subscribe
  end

  def subscribe_to_all_projects_link
    link_to t('.subscribe_to_all'),
      user_rss_token(projects_path(:format => :rss)),
      :class => 'subscribe subscribe_all'
  end

  def subscribe_to_project_link(project)
    link_to t('.subscribe_to_project', :project => project),
      user_rss_token(project_path(project, :format => :rss)),
      :class => :subscribe
  end

  def instructions_for_calendars
    link_to t('shared.instructions.subscribe_to_calendars'), calendars_path, :class => :calendars_link
  end

  def instructions_for_email(project)
    suffix = ''
    case location_name
      when 'show_projects' #project@app.teambox.com
        email_help = t('shared.instructions.send_email_help_project_html', :email => "#{project.permalink}@#{Teambox.config.smtp_settings[:domain]}")
      when 'show_tasks' #project+task+12@app.teambox.com
        email_help = t('shared.instructions.send_email_help_task_html', :email => "#{project.permalink}+task+#{@task.id}@#{Teambox.config.smtp_settings[:domain]}")
      when 'index_conversations' #project+conversation@app.teambox.com
        email_help = t('shared.instructions.send_email_help_conversations_html', :email => "#{project.permalink}+conversation@#{Teambox.config.smtp_settings[:domain]}")
        suffix = '_conversations'
      when 'new_conversations' #project+conversation@app.teambox.com
        email_help = t('shared.instructions.send_email_help_conversations_html', :email => "#{project.permalink}+conversation@#{Teambox.config.smtp_settings[:domain]}")
        suffix = '_conversations'
      when 'show_conversations' #project+conversation+5@app.teambox.com
        email_help = t('shared.instructions.send_email_help_conversation_html', :email => "#{project.permalink}+conversation+#{@conversation.id}@#{Teambox.config.smtp_settings[:domain]}")
    end

    if email_help
      span = content_tag(:span, :id => 'email_help', :style => 'display:none') do
        %(<p>#{email_help}</p><a href='#' class='closeThis'>#{t('common.close')}</a>).html_safe
      end
      link_to_function(t('shared.instructions.send_email' + suffix),
        ("$('email_help').toggle()".html_safe), :class => :email_link) + span
    end
  end

  def subscribe_to_all_calendars_link
    content_tag(:div,
      (t('.subscribe_to_all') +
      link_to(t('shared.task_navigation.all_tasks'), user_rss_token(projects_path(:format => :ics))) +
      ' ' + t('common.or') + ' ' +
      link_to(t('shared.task_navigation.my_assigned_tasks'), user_rss_token(projects_path(:format => :ics), 'mine'))).html_safe,
      :class => 'calendar_links_all')
  end

  def subscribe_to_calendar_link(project)
    content_tag(:div,
      (t('.subscribe_to_project', :project => h(project)) +
      link_to(t('shared.task_navigation.all_tasks'), user_rss_token(project_path(project, :format => :ics))) +
      ' ' + t('common.or') + ' ' +
      link_to(t('shared.task_navigation.my_assigned_tasks'), user_rss_token(project_path(project, :format => :ics), 'mine'))).html_safe,
      :class => :calendar_links)
  end

  def leave_project_link(project)
    person = current_user.people.detect { |p| p.project_id == project.id }
    unless !person
      link_to t('people.column.leave_project'),
        project_person_path(project, person),
        :method => :delete, :confirm => t('people.column.confirm_delete'), :class => :leave_link
    end
  end

  def join_project_link(project)
    msg = ""
    if project.organization.is_admin?(current_user)
      msg = t('projects.not_in_project.explain_admin_html', :organization => h(@current_project.organization))
      link_to t('projects.not_in_project.join'), join_project_path(project), :title => msg, :class => :join_link
    elsif project.public
      msg = t('projects.not_in_project.explain_public_html', :organization => h(@current_project.organization))
      link_to t('projects.not_in_project.join'), join_project_path(project), :title => msg, :class => :public_link
    end
  end
  
  def options_for_projects(projects)
    projects.map {|project| [ project.name, project.id ]}
  end
  
  def options_for_owned_projects(user, projects)
    projects.reject{|p| p.user_id != user.id}.map {|p| [ p.name, p.id ]}
  end

  def projects_people_data
    javascript_tag "_people = #{projects_people_data_json}"
  end

  def projects_people_data_json
    Rails.cache.fetch "projects_people_data.#{current_user.id}" do
      Person.people_data_for_user(current_user)
    end.to_json
  end

  def project_link_with_overlay(project)
    content_tag :div, :class => :project_overlay do
      link_to project, project, :'data-project-id' => project.id 
    end
  end
end
