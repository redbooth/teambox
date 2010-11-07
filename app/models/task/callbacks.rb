class Task

  def before_create
    self.position ||= task_list.tasks.last ? task_list.tasks.last.position + 1 : 0
  end

  def after_create
    project.log_activity(self, 'create')
  end

  def before_save
    add_watcher(assigned.user, false) if assigned
    true
  end

  def after_destroy
    Activity.destroy_all  :target_id => self.id, :target_type => self.class.to_s
    Comment.destroy_all   :target_id => self.id, :target_type => self.class.to_s
  end
end  