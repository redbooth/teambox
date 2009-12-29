class TaskList < RoleRecord
  acts_as_list :scope => :project
  attr_accessible :name, :start_on, :finish_on

  serialize :watchers_ids

  concerned_with :validation, 
                 :initializers, 
                 :scopes, 
                 :associations,
                 :callbacks

  def after_comment(comment)
    notify_new_comment(comment)
  end
  
  def notify_new_comment(comment)
    self.watchers.each do |user|
      if user != comment.user and user.notify_task_lists
        Emailer.deliver_notify_task_list(user, self.project, self)
      end
    end
  end
  
  def user
    User.find_with_deleted(user_id)
  end
end