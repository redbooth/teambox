require 'rss_feed_helper'

module ActivitiesHelper

  def activity_project_link(project)
    if project
      out = " "
      out << "<span class='project'>"
      out << "#{t('common.in_project')} "
      out <<   link_to(h(project), project_path(project))
      out << "</span>"
      out.html_safe
    end
  end
  
  def activity_section(activity)
    haml_tag 'div', :class => "activity #{activity.action_type}" do
      haml_concat micro_avatar(activity.user)
      haml_tag 'div', :class => :activity_block do
        haml_tag 'div', posted_date(activity.created_at), :class => :date unless rss?
        yield activity_title(activity)
      end
    end
  end

  # TODO for activities create_note, create_divider, edit and delete
  ActivityTypes = %w( create_comment 
                      create_conversation
                      create_task_list
                      create_task
                      create_page edit_page
                      create_note edit_note
                      create_upload
                      create_person delete_person
                      create_project
                      create_teambox_data
                      )

  def list_activities(activities)
    activities.map { |activity| show_activity(activity) }.join('').html_safe
  end

  def list_threads(activities)
    activities.map { |activity| show_threaded_activity(activity) }.join('').html_safe
  end

  def show_threaded_activity(activity)
    if activity.thread_id.starts_with? "Task_" or activity.thread_id.starts_with? "Conversation_"
      mode = %w(projects activities).include?(controller.controller_name) ? "short" : "full"
      Rails.cache.fetch("#{mode}-thread/#{activity.thread_id}/#{current_user.locale}") do
        render('activities/thread', :activity => activity).to_s
      end
    else
      Rails.cache.fetch("#{activity.cache_key}/#{current_user.locale}") do
        show_activity(activity).to_s
      end
    end
  end


  def show_activity(activity)
    if activity.target && ActivityTypes.include?(activity.action_type)
      render "activities/#{activity.action_type}", :activity => activity,
        activity.target_type.underscore.to_sym => activity.target
    end
  end
  
  def activity_title(activity, plain = false, mobile = false)
    values = mobile ? { :user => (plain ? h(activity.user.short_name) : "<span class='user'>#{h activity.user.short_name}</span>") } :
                      { :user => link_to_unless(plain, h(activity.user.name), activity.user) }
    
    case activity
    when Comment
      object = activity
      type = 'create_comment'
    when Upload
      object = activity
      type = 'create_upload'
    else
      object = activity.target
      type = activity.action_type
    end
    
    values.update case type
    when 'create_note', 'edit_note'
      page = Page.find_with_deleted(object.page_id)
      { :note => object,
        :page => link_to_unless(plain || page.deleted?, h(page), [activity.project, page]) }
    when 'create_conversation'
      { :conversation => link_to_unless(plain, h(object), [activity.project, object]) }
    when 'create_page', 'edit_page'
      { :page => link_to_unless(plain || object.deleted?, h(object), [activity.project, object]) }
    when 'create_person', 'delete_person'
      { :person => link_to_unless(plain, h(object.user.name), object.user),
        :project => link_to_unless(plain, h(activity.project), activity.project) }
    when 'create_task'
      { :task => link_to_unless(plain, h(object), [activity.project, object]),
        :task_list => link_to_unless(plain, h(object.task_list), [activity.project, object.task_list]) }
    when 'create_task_list'
      { :task_list => link_to_unless(plain, h(object), [activity.project, object]) }
    when 'create_teambox_data'
      { :person => link_to_unless(plain, h(object.user.name), object.user),
        :project => link_to_unless(plain, h(activity.project), activity.project) }
    when 'create_upload'
      text = object.description.presence || object.file_name
      { :file => link_to_unless(plain, h(text), project_uploads_path(activity.project, :anchor => dom_id(object))) }
    when 'create_project'
      { :person => link_to_unless(plain, h(activity.user), activity.user),
        :project => link_to_unless(plain, h(activity.project), activity.project) }
    when 'create_comment'
      # one of Project, Task or Conversation
      object = object.target
      type << "_#{object.class.name.underscore}"
      
      target = case object
      when Task then link_to_unless(plain, h(object.name), [object.project, object])
      when Project then link_to_unless(plain, h(object.name), object)
      when Conversation then link_to_unless(plain, h(object.name), [object.project, object])
      end
      { :target => target }
    else
      raise ArgumentError, "unknown activity type #{type}"
    end
    t("activities.#{type}.title", values).html_safe
  end
  
  def activity_target_url(activity)
    if activity.target_type == 'Task'
      task = activity.target
      project_task_url(activity.project, task)
    elsif activity.comment_target_type == 'Task'
      task = activity.comment_target
      project_task_url(activity.project, task)
    elsif activity.target_type == 'TaskList'
      project_task_list_url(activity.project, activity.target)
    elsif activity.target_type == 'Page'
      project_page_url(activity.project, activity.target)
    elsif activity.target_type == 'Upload'
      project_uploads_url(activity.project)
    elsif activity.target_type == 'Conversation'
      project_conversation_url(activity.project, activity.target)
    elsif activity.comment_target_type == 'Conversation'
      project_conversation_url(activity.project, activity.comment_target)
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
        item.title @view.activity_title(activity, true)
        body = @view.show_activity(activity)
        item.description body
        item.tag! 'content:encoded', body
        item.author activity.user.name
      end
      super(activity, options, &block)
    end
  end
  
  def activities_paginate_link(*args)
    options = args.extract_options!

    if location_name == 'index_projects' or location_name == 'show_activities'
      url = show_more_path(options[:last_activity].id)
    elsif location_name == 'show_more_activities' and params[:project_id].nil? and params[:user_id].nil?
      url = show_more_path(options[:last_activity].id)
    elsif location_name == 'show_users'
      url = user_show_more_path(@user.id, options[:last_activity].id)
    elsif location_name == 'show_projects'
      url = project_show_more_path(@current_project.permalink, options[:last_activity].id)
    elsif location_name == 'show_more_activities' and params[:project_id]
      url = project_show_more_path(params[:project_id], options[:last_activity].id)
    elsif location_name == 'show_more_activities' and params[:user_id]
      url = user_show_more_path(params[:user_id], options[:last_activity].id)
    else
      raise "unexpected location #{location_name}"
    end
    link_to(content_tag(:span, t('common.show_more')),
            url,
            :remote => true,
            :class => 'activity_paginate_link button',
            :id => 'activity_paginate_link'
            )
  end
  
  def show_more(after)
    update_page do |page|
      page['activities'].insert list_activities(@activities)
    end
  end
  
  def show_more_button
    render 'activities/show_more' if @last_activity
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
