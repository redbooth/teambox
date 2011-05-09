class ThreadsObserver < ActiveRecord::Observer
  observe :comment, :conversation, :task, :project

  def after_update(record)
    case record
    when Comment
      expire_with_locales "#{record.thread_id}"
    when Conversation
      expire_with_locales "Conversation_#{record.id}"
    when Task
      expire_with_locales "Task_#{record.id}"
    when Project
      expire_all_with_locales record if record.permalink_changed? or record.name_changed?
    end
  end

  def after_create(record)
    case record
    when Comment
      expire_with_locales "#{record.thread_id}"
    end
  end
  
  def after_destroy(record)
    case record
    when Comment
      expire_with_locales "#{record.thread_id}"
    end
  end
  
  protected

    def expire_with_locales(thread_id)
      I18n.available_locales.each do |locale|
        Rails.cache.delete "full-thread/#{thread_id}/#{locale}"
        Rails.cache.delete "short-thread/#{thread_id}/#{locale}"
      end
    end

    def expire_all_with_locales(project)
      project.activities.select([:target_id, :target_type]).where(:target_type => ['Conversation', 'Task']).map(&:thread_id).uniq.each do |thread_id|
        expire_with_locales(thread_id)
      end
    end
end