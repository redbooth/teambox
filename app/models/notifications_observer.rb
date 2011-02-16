class NotificationsObserver < ActiveRecord::Observer

  observe :comment


  method_args = %w(cucumber test).any? {|env| Rails.env == env} ? ['after_create']: ['after_commit', {:on => :create}]

  define_method(*method_args) do |obj|
    case obj
      when Comment
        notify_watchers_on_new_comment(obj)
    end
  end

  protected

    def notify_watchers_on_new_comment(comment)
      return if comment.try(:project).try(:is_importing)

      case target = comment.target
        when Conversation then conversation_new_comment(target, comment)
        when Task then task_new_comment(target, comment)
      end
    end

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
