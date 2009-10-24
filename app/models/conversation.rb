class Conversation < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  
  has_many :uploads
  has_many :comments, :as => :target, :order => 'created_at DESC'

  serialize :followers_ids

  attr_accessible :name
  attr_accessor :body

  def after_create
    self.project.log_activity(self,'create')
    self.add_follower self.user

    comment = self.comments.new do |comment|
      comment.project_id = self.project_id
      comment.user_id = self.user_id
      comment.body = self.body
    end
    
    comment.save!
  end
  
  def owner?(u)
    user == u
  end

  def notify_new_comment(comment)
    self.followers.each do |user|
      unless user == current_user
        Emailer.deliver_notify_conversation(user.email, comment.project, comment, self)
      end
    end
  end

  def add_follower(user)
    self.followers_ids ||= []
    self.followers_ids << user.id
    self.save
  end

  def remove_follower(user)
    self.followers_ids ||= []
    self.followers_ids.delete user.id
    self.save
  end
  
  def followers
    return [] unless self.followers_ids
    self.followers_ids.collect do |id|
      User.find id, :select => "id, email, name, language"
    end
  end
end