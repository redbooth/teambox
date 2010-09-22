class Task
  def after_create
    project.log_activity(self, 'create')
  end

  def before_save
    unless position
      last_position = task_list.tasks.first(:select => 'position')
      self.position = last_position.try(:position).try(:succ) || 1
    end
    add_watcher(assigned.user, false) if assigned
    true
  end

  def after_destroy
    Activity.destroy_all  :target_id => self.id, :target_type => self.class.to_s
    Comment.destroy_all   :target_id => self.id, :target_type => self.class.to_s
  end
end  