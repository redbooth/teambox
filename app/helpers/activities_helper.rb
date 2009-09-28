module ActivitiesHelper
  def list_activities(activities)
    render :partial => 'activities/activity', :collection => activities
  end
  
  def show_activity(activity)
    target_class = activity.target.class.name.downcase
    if target_class == 'nilclass'
      render(:partial => 'activities/deleted')
    else
      render(:partial => "activities/#{activity.target.class.name.downcase}_#{activity.action}",
        :locals => { :activity => activity })
    end
  end
  
  def link_to_conversation(conversation)
    link_to conversation.name, project_conversation_path(conversation.project, conversation)
  end
  
  def link_to_task_list(task_list)
    link_to task_list.name, project_task_list_path(task_list.project, task_list)
  end

  def link_to_task(task)
    link_to task.name, project_task_list_task_path(task.project, task.task_list, task)
  end

end