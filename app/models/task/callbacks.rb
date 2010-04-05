class Task
  def after_create
    project.log_activity(self,'create')
    add_watcher(self.user)
    create_comment_if_present
  end

  def before_save
    unless position
      last_position = task_list.tasks.first(:select => 'position')
      self.position = last_position.try(:position).try(:succ) || 1
    end
    if assigned.try(:user) && watchers_ids && !watchers_ids.include?(assigned.user.id)
      add_watcher(assigned.user)
    end
  end

  def after_destroy
    Activity.destroy_all  :target_id => self.id, :target_type => self.class.to_s
    Comment.destroy_all   :target_id => self.id, :target_type => self.class.to_s
  end
  
  protected
  
    def create_comment_if_present
      if @body && !@body.empty?
        comment = comments.new
        comment.user = user
        comment.body = @body
        comment.project = project
        comment.save!
      end
    end
end  