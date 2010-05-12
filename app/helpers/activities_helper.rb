require 'rss_feed_helper'

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
                      create_page edit_page
                      create_note edit_note
                      create_divider edit_divider
                      create_upload
                      create_person delete_person)

  def list_activities(activities)
    render :partial => "activities/activity", :collection => activities
  end

  def show_activity(activity)
    if activity.target && ActivityTypes.include?(activity.action_type)
      render "activities/#{activity.action_type}", :activity => activity,
        activity.target_type.underscore.to_sym => activity.target
    end
  end
  
  def activity_target_url(activity)
    if activity.target_type == 'Task'
      task = activity.target
      project_task_list_task_url(activity.project, task.task_list_id, task)
    elsif activity.comment_type == 'Task'
      task = activity.target.target
      project_task_list_task_url(activity.project, task.task_list_id, task)
    elsif activity.target_type == 'TaskList'
      project_task_list_url(activity.project, activity.target)
    elsif activity.target_type == 'Page'
      project_page_url(activity.project, activity.target)
    elsif activity.target_type == 'Upload'
      project_uploads_url(activity.project)
    elsif activity.target_type == 'Conversation'
      project_conversation_url(activity.project, activity.target)
    elsif activity.comment_type == 'Conversation'
      project_conversation_url(activity.project, activity.target.target)
    else
      project_url(activity.project, :anchor => "activity_#{activity.id}")
    end
  end
  
  def rss_activity_feed(options, &block)
    i18n_values = {}
    project = options.delete(:project)
    i18n_values[:name] = project.name if project
    
    options[:xml] ||= eval("xml", block.binding)
    options[:builder] = ActivityFeedBuilder
    
    rss_feed(options) do |feed|
      feed.title t('.rss.title', i18n_values)
      feed.description t('.rss.description', i18n_values)
      
      yield feed
    end
  end
  
  class ActivityFeedBuilder < RssFeedHelper::RssFeedBuilder
    def entry(activity, options = {}, &block)
      options[:published] ||= activity.posted_date
      options[:url] ||= @view.activity_target_url(activity)
      
      block ||= Proc.new do |item|
        item.title @view.t("activities.#{activity.action_type}.#{activity.action_type}")
        item.description @view.show_activity(activity)
        item.author activity.user.name
      end
      super(activity, options, &block)
    end
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
  
  def fluid_badge(count)
    badge = "if (typeof(badge_count) != 'undefined') 
                { badge_count += #{count}; }
            else  badge_count = #{count};"
    badge << "window.fluid.dockBadge = badge_count+'';"
    badge << "ClearBadge = window.onfocus=function(){window.fluid.dockBadge = ''; badge_count = 0};"
  end
  
  def fluid_growl(project, user, body)
    "window.fluid.showGrowlNotification({
        title: '#{project}', 
        description: '#{user}: #{body}'
    });"
  end
end