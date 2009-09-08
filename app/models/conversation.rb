class Conversation < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  
  has_many :comments, :as => :target, :order => 'created_at DESC'
  
  attr_accessible :name
  
  def after_create
    self.project.log_activity(self,'add')
  end
end