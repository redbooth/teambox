class Comment
  
  has_many :uploads
  accepts_nested_attributes_for :uploads, :allow_destroy => true
  attr_accessible :upload_ids, :uploads_attributes

  belongs_to :user
  belongs_to :project
  belongs_to :target, :polymorphic => true, :counter_cache => true
  belongs_to :assigned, :class_name => 'Person'
  belongs_to :previous_assigned, :class_name => 'Person'  

  accepts_nested_attributes_for :target
  
end