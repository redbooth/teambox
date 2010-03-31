class Task
  def after_create
    self.project.log_activity(self,'create')
    self.add_watcher(self.user)
  end

  def before_save
    unless position
      last_position = self.task_list.tasks.first(:select => 'position')
      self.position = last_position.nil? ? 1 : last_position.position.succ
    end
    if self.watchers_ids and assigned and assigned.user and not self.watchers_ids.include?(assigned.user.id)
      self.add_watcher(assigned.user)
    end
  end

  def after_destroy
    Activity.destroy_all  :target_id => self.id, :target_type => self.class.to_s
    Comment.destroy_all   :target_id => self.id, :target_type => self.class.to_s
  end
end  