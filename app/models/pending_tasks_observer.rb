class PendingTasksObserver < ActiveRecord::Observer
  observe :person, :task, :project

  def after_save(record)
    case record
    when Person
      record.user.clear_pending_tasks!
    when Task
      assigned = Person.find_by_id(record.assigned_id) if record.assigned_id
      assigned_was = Person.find_by_id(record.assigned_id_was) if record.assigned_id_changed? and record.assigned_id_was

      assigned.user.clear_pending_tasks! if assigned and assigned.user
      assigned_was.user.clear_pending_tasks! if assigned_was and assigned_was.user
    when Project
      if record.archived_changed?
        Person.where(:project_id => record.id).each do |person|
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

