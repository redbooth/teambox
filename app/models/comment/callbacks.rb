class Comment

  def before_create
    self.target ||= project

    set_status_and_assigned if self.target.is_a?(Task)
  end

  def after_create
    self.target.reload
    
    @activity = project && project.log_activity(self, 'create')

    target.after_comment(self)      if target.respond_to?(:after_comment)
    target.add_watchers(@mentioned) if target.respond_to?(:add_watchers)
    target.notify_new_comment(self) if target.respond_to?(:notify_new_comment)
  end
  
  def after_destroy
    Activity.destroy_all :target_type => self.class.to_s, :target_id => self.id
  end
  
  protected

    def set_status_and_assigned
      self.previous_status      = target.previous_status
      self.assigned             = target.assigned
      self.previous_assigned_id = target.previous_assigned_id
      if status == Task::STATUSES[:open] && !assigned
        self.assigned = Person.find(:first, :conditions => { :user_id => user.id, :project_id => project.id })
      end
    end
    
end