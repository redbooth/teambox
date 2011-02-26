class NotificationsObserver < ActiveRecord::Observer

  observe :comment, :activity


  method_name = %w(cucumber test).any? {|env| Rails.env == env} ? :after_create : :after_commit

  define_method(method_name) do |obj|
    return if method_name == :after_commit && !obj.send(:transaction_include_action?, :create)

    case obj
      when Activity
        push_on_create(obj)
      when Comment
        notify_watchers_on_new_comment(obj)
    end
  end

  protected

    def push_on_create(activity)
      activity_hash = activity.to_push_data(:include => [:project, :target, :user])

      #TODO: Also send none project-related activities
      if activity.project && !activity.is_first_comment?
        activity.project.users.each do |user|
          Juggernaut.publish("/users/#{user.authentication_token}", activity_hash.to_json)
        end
      end
    end

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
