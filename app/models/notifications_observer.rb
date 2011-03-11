class NotificationsObserver < ActiveRecord::Observer

  observe :comment


  method_name = %w(cucumber test).any? {|env| Rails.env == env} ? :after_create : :after_commit

  define_method(method_name) do |obj|
    return if method_name == :after_commit && !obj.send(:transaction_include_action?, :create)

    case obj
      when Comment
        notify_watchers_on_new_comment(obj)
    end
  end

  protected

    def notify_watchers_on_new_comment(comment)
      return if comment.try(:project).try(:is_importing)
      return unless %w(Conversation Task).any? {|target_type| comment.target_type == target_type}

      target = comment.target

      target.people_watching.each do |person|
        next if person.user == comment.user
        user = person.user
        if user.send("notify_#{target.class.to_s.downcase.pluralize}".to_sym)
          notification = person.notifications.new
          notification.comment = comment
          notification.target = target
          notification.user = user

          if person.digest_type == :instant or (comment.mentioned.to_a.include? user and user.instant_notification_on_mention?)
            instant_delivery(target, comment, user)
            notification.sent = true
          else
            person.update_next_delivery_time!
          end

          notification.save
          user.increment!(:unread_notifications_count)
        end
      end
    end

    def instant_delivery(target, comment, user)
      Emailer.send_with_language("notify_#{target.class.to_s.downcase}".to_sym, user.locale, user.id, comment.project.id, target.id)
    end
end
