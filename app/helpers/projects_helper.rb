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
    out = t('projects.fields.permalink_prefix', :domain => APP_CONFIG['app_domain'])
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
    unless @projects.empty?
    render :partial => 'shared/projects', :locals => { :projects => projects }
    end
  end
  
  def project_link(project)
    link_to h(project.name), project_path(project)
  end
  
  def new_project_link
    link_to content_tag(:span, t('.new_project')), new_project_path, :class => 'add_button', :id => 'new_project_link'
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
  
  def subscribe_to_projects_link
    content_tag(:div, 
      link_to(t('.subscribe'), user_rss_token(projects_path(:format => :rss))),
      :class => :subscribe)
  end

  def subscribe_to_project_link(project)
    content_tag(:div, 
      link_to(t('common.print'), user_rss_token(project_path(@current_project, :format => :rss))),
      :class => :print)
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

  def reset_autorefresh
    "clearInterval(autorefresh)"
  end

  def autorefresh(activities)
    ajax_request = remote_function(:url => show_new_path(@activities.first.id))
        
    interval = APP_CONFIG['autorefresh_interval']*1000

    "autorefresh = setInterval(\"#{ajax_request}\", #{interval})"
  end
end