class Project < ActiveRecord::Base
  belongs_to :user
  has_many :task_lists
  
  validates_length_of :name, :minimum => 3
  validates_uniqueness_of :permalink
  validates_format_of :permalink, :with => /^[a-z0-9_\-\.]{2,}$/
  
  attr_accessible :name, :permalink
  
  has_permalink :name
  
  def to_param
    permalink
  end
  
end