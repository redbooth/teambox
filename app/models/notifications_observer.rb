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
      activity_hash = activity.to_api_hash(:include => [:project, :target, :user])
      Juggernaut.publish("/projects/#{activity_hash[:project][:permalink]}", activity_hash.to_json)
    end

    def notify_watchers_on_new_comment(comment)
      return if comment.try(:project).try(:is_importing)
      return unless %w(Conversation Task).any? {|target_type| comment.target_type == target_type}

      target = comment.target

      target.people_watching.each do |person|
        next if person.user == comment.user
        user = person.user
        if user.send("notify_#{target.class.to_s.downcase.pluralize}".to_sym)
          notification = person.notifications.new(:comment => comment, :target => target, :user => user)

          if person.digest_type == :instant or (comment.mentioned.to_a.include? user and user.instant_notification_on_mention?)
            instant_delivery(target, comment, user)
            notification.sent = true
          elsif person.digest_type != :none
            person.update_next_delivery_time!
          end

          # Set all the notification as read until we have a nice UI for it
          # Todo, remove once we have a UI for it
          notification.read = true

          notification.save
        end
      end
    end

    def instant_delivery(target, comment, user)
      Emailer.send_with_language("notify_#{target.class.to_s.downcase}".to_sym, user.locale, user.id, comment.project.id, target.id)
    end
end
