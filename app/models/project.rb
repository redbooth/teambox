class Project < ActiveRecord::Base
  belongs_to :user
  
  validates_length_of :name, :minimum => 3
  
  attr_accessible :name
  
  has_permalink :name
  
  def to_param
    permalink
  end
  
end