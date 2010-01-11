module ActivitiesHelper

  def activity_project_link(project, arrow_pos = :before)
    if project
      out = ""
      out << " <span class='arr project_arr'>&rarr;</span> " if arrow_pos == :before
      out << "<span class='project'>"
      out <<   link_to(project, project_path(project))
      out << "</span>"
      out << " <span class='arr project_arr'>&rarr;</span> " if arrow_pos == :after
      out
    end  
  end

  # TODO for activities create_note, create_divider, edit and delete
  ActivityTypes = %w( create_comment 
                      create_conversation
                      create_task_list
                      create_task
                      create_page
                      create_upload
                      create_person delete_person)

  def list_activities(activities)
    activities.collect { |a| show_activity(a) }
  end

  def show_activity(activity)
    # Activity#target is redefined so it finds deleted elements too
    if activity.target && ActivityTypes.include?(activity.action_type)
      render_activity_partial(activity,activity.target)
    end
  end
  
  def render_activity_partial(activity,target)
    render :partial => "activities/#{activity.action_type}",
      :locals => {
        :activity => activity,
        activity.target_type.underscore.to_sym => target }
  end
  
  def link_to_conversation(conversation)
    link_to conversation, project_conversation_path(conversation.project, conversation)
  end
  
  def link_to_task_list(task_list)
    link_to task_list, project_task_list_path(task_list.project, task_list)
  end

  def link_to_task(task)
    link_to task, project_task_list_task_path(task.project, task.task_list,task)
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