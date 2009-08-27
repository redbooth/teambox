class Conversation < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  
  attr_accessible :name
end