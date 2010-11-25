class GoogleDoc < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :comment
  
  validates_presence_of :title
  validates_presence_of :url
  validates_presence_of :document_type
  
  attr_accessible :title, :document_type, :url, :edit_url, :acl_url
end
