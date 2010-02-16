class Conversation < RoleRecord
  has_many :uploads
  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy

  serialize :watchers_ids

  attr_accessible :name
  attr_accessor :body

  def after_create
    project.log_activity(self,'create')
    add_watcher(self.user) 

    if @body
      comment = self.comments.new do |comment|
        comment.project_id = self.project_id
        comment.user_id = self.user_id
        comment.body = self.body
      end

      comment.save!
    end
  end
  
  def after_destroy
    Activity.destroy_all  :target_id => self.id, :target_type => self.class.to_s
  end

  def owner?(u)
    user == u
  end

  def notify_new_comment(comment)
    self.watchers.each do |user|
      if user != comment.user and user.notify_conversations
        Emailer.deliver_notify_conversation(user, self.project, self)
      end
    end
    self.sync_watchers
  end
  
  def to_s
    name
  end
end