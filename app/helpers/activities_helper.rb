module ActivitiesHelper

  def activity_project_link(project)
    unless project.nil?
      out = "<span class='arr project_arr'>&rarr;</span> " 
      out << "<span class='project'>"
      out <<  link_to(project.name, project_path(project))
      out << "</span>"
      out
    end  
  end

  def list_activities(activities)
    render :partial => 'activities/activity', :collection => activities
  end
  
  def show_activity(project,activity,target)
    if target #dirty hack for when activities exist and there target doesn't
      case activity.action_type  
        when 'create_comment'
          show_comment(target)
        when 'create_upload'
          # Uploads will already be shown in their parent comment.
          # We will only show them if they're not attached to a comment.
          # BUT we should show new versions uploaded for existing files.        
          show_upload(target) unless target.comment_id
        when 'create_conversation'
          show_activity_line(activity,the_conversation_link(target))
        when 'create_task_list'
          show_activity_line(activity,the_task_list_link(target))
        when 'create_page'
          show_activity_line(activity,'') #edit_page_link(project,target))
        when 'create_person'
          show_activity_line(activity,the_person_link(project,target))
        else  
          render 'activities/deleted'
      end
    end  
  end

  def show_activity_line(activity,action_link)
    render :partial => "activities/activity_line", :locals => { :activity => activity, :action_link => action_link }
  end
  
  def link_to_conversation(conversation)
    link_to conversation.name, project_conversation_path(conversation.project, conversation)
  end
  
  def link_to_task_list(task_list)
    link_to task_list.name, project_task_list_path(task_list.project, task_list)
  end

  def link_to_task(task)
    link_to task.name, project_task_list_task_path(task.project, task.task_list,task)
  end

  def activities_paginate_link(*args)
    options = args.extract_options!

    if location_name == 'index_projects'
      url = show_more_path(options[:last_activity].id)
    elsif location_name == 'show_more_activities' and params[:project_id].nil?
      url = show_more_path(options[:last_activity].id)
    elsif location_name == 'show_projects'
      url = project_show_more_path(@current_project.id, options[:last_activity].id)
    elsif location_name == 'show_more_activities' and params[:project_id]
      url = project_show_more_path(params[:project_id], options[:last_activity].id)
    else
      raise "unexpected location #{location_name}"
    end
    link_to_remote content_tag(:span, t('common.show_more', :number => APP_CONFIG['activities_per_page'])),
      :url => url,
      :loading => activities_paginate_loading,
      :html => {
        :class => 'activity_paginate_link button',
        :id => 'activity_paginate_link' }
  end
  
  def activities_paginate_loading
    update_page do |page|
      page['activity_paginate_link'].hide
      page['activity_paginate_loading'].show
    end
  end

  def show_more(after)
    update_page do |page|
      page['activities'].insert list_activities(@activities)
    end
  end
  
  def show_more_button(activities)
    if activities.size == APP_CONFIG['activities_per_page']
      render :partial => 'activities/show_more'
    end
  end

end