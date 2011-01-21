class PendingTasksObserver < ActiveRecord::Observer
  observe :person, :task, :project

  def after_save(record)
    case record
    when Person
      record.user.clear_pending_tasks!
    when Task
      Person.find(record.assigned_id).user.clear_pending_tasks! if record.assigned_id
      Person.find(record.assigned_id_was).user.clear_pending_tasks! if record.assigned_id_changed? and record.assigned_id_was
    when Project
      if record.archived_changed?
        record.people.each do |person|
          person.user.clear_pending_tasks!
        end
      end
    end
  end

  def after_destroy(record)
    case record
    when Person
      record.user.clear_pending_tasks!
    when Task
      Person.find(record.assigned_id).user.clear_pending_tasks! if record.assigned_id
    when Project
      record.people.each do |person|
        person.user.clear_pending_tasks!
      end
    end
  end

end
