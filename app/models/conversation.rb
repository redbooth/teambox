class Conversation < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  
  has_many :uploads
  has_many :comments, :as => :target, :order => 'created_at DESC'
  
  attr_accessible :name
  attr_accessor :body
  
  def after_create
    self.project.log_activity(self,'add')

    comment = self.comments.new do |comment|
      comment.project_id = self.project_id
      comment.user_id = self.user_id
      comment.body = self.body
    end
    
    comment.save!
  end

  def get_comments(user,show = 'all')
    if user.comments_ascending
      order = 'comments.created_at ASC'
    else
      order = 'comments.created_at DESC'
    end

    if show == 'hours'  
      self.comments.find(:all,:conditions => [ 'hours IS NOT NULL and hours > 0'], :order => order)
    elsif show == 'uploads'
      self.comments.find(:all,
        :select => 'comments.*',
        :joins => 'INNER JOIN uploads ON (uploads.comment_id = comments.id)',
        :order => order)
    else
      self.comments.find(:all,:order => order)
    end
  end
  
end