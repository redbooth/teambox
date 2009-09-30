module ActivitiesHelper
  def list_activities(activities)
    render :partial => 'activities/activity', :collection => activities
  end
  
  def show_activity(project,activity,target)
    case activity.action_type  
      when 'create_comment'
        show_comment(target)
      when 'create_upload'
        show_upload(target)
      when 'create_conversation'
        show_activity_line(activity,conversation_link(project,target))
      when 'create_task_list'
        show_activity_line(activity,task_list_link(target))
      when 'create_page'
        show_activity_line(activity,edit_page_link(project,target))
      when 'create_person'
        show_activity_line(activity,person_link(project,target))
      else  
        render 'activities/deleted'
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

end