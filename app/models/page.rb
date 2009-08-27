class Page < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  
  acts_as_versioned
  
  attr_accessible :name, :body
end