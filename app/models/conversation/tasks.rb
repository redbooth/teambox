class Conversation
  attr_accessor :due_on, :status, :assigned_id, :task_list_id
  attr_accessible :due_on, :status, :assigned_id, :task_list_id

  def convert_to_task!
    task_list = task_list_id.blank? ? nil : TaskList.find(task_list_id)
    task_list ||= TaskList.find_or_create_by_name_and_project_id_and_user_id('Inbox', project.id, user.id)
    assigned_person = project.people.find(assigned_id) if assigned_id && (assigned_id != 'Unassigned')

    task = project.tasks.create do |t|
      t.name = name
      t.status = status.blank? ? 0 : status
      t.due_on = due_on
      t.user = user 
      t.updating_user = updating_user
      t.task_list = task_list
      t.assigned = assigned_person
      t.created_at = created_at
    end

    task.errors.each {|attr,msg| errors.add(attr, msg)}

    if task
      #destroy newly created activities
      Activity.for_tasks.in_targets(task).each(&:destroy)

      comments.each do |comment|
        comment.attributes = {:status => nil, :assigned_id => nil, :previously_assigned_id => nil}
        comment.target = task
        comment.update_record_without_timestamping
        task.comments << comment
      end

      task.class.update_counters(task.id, :comments_count => comments.size)
      task.comments_count = comments.size

      Activity.for_conversations.in_targets(self).each do |activity|
        activity.target = task if activity.target == self
        if activity.comment_target_type == self.class.name
          activity.comment_target_type = task.class.name
          activity.comment_target_id = task.id
        end
        if activity.target == task && activity.action == 'create'
          activity.save
        else
          activity.update_record_without_timestamping
        end
      end

      task.save
      self.reload.destroy
    end
    task
  end
end
