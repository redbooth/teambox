class TaskList < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  
  validates_length_of :name, :minimum => 3
  
  attr_accessible :name
end