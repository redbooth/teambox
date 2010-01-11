module MobileHelper

  def mobile_show_activity(activity)
    target  = activity.target
    project = activity.project
    return unless target && project
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