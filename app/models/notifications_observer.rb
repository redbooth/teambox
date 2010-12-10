class NotificationsObserver < ActiveRecord::Observer

  observe :comment
  
  def after_create(obj)
    return if obj.try(:project).try(:is_importing)
    case obj
    when Comment
      case target = obj.target
      when Conversation then conversation_new_comment(target, obj)
      when Task then task_new_comment(target, obj)
      end
    end
  end

  protected

    def conversation_new_comment(target, comment)
      (target.watchers - [comment.user]).each do |user|
        if user.notify_conversations
          Emailer.send_with_language(:notify_conversation, user.locale, user.id, comment.project.id, target.id) # deliver_notify_conversation
        end
      end
    end

    def task_new_comment(target, comment)
      (target.watchers - [comment.user]).each do |user|
        if user.notify_tasks
          Emailer.send_with_language(:notify_task, user.locale, user.id, comment.project.id, target.id) # deliver_notify_task
        end
      end
    end

end