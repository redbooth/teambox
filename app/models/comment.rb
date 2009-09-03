class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, :polymorphic => true
  
  attr_accessible :body
  formats_attributes :body
  
  def after_create
    target.last_comment_id = id
    target.save(false)
  end
end