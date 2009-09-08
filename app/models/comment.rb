class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, :polymorphic => true
  belongs_to :project
  
  attr_accessible :body
  formats_attributes :body
  
  attr_accessor :activity
  
  def after_create
    target.last_comment_id = id
    target.save(false)
    
    self.activity = project.log_activity(self,'add')
  end
end