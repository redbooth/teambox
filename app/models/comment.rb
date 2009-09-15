class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, :polymorphic => true
  belongs_to :project
  has_many :uploads
    
  attr_accessible :body, :hours
  formats_attributes :body

  named_scope :ascending, :order => 'created_at ASC'
  named_scope :descending, :order => 'created_at DESC'
  named_scope :with_uploads, :conditions => 'hours > 0'
  named_scope :with_hours, :conditions => 'hours > 0'

  attr_accessor :activity
  
  def after_create
    target.last_comment_id = id
    target.save(false)
    
    self.activity = project.log_activity(self,'add')
  end
  
end