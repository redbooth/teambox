class Divider < ActiveRecord::Base
  belongs_to :page
  belongs_to :project
  acts_as_paranoid
    
  formats_attributes :body
    
  attr_accessor :deleted
  attr_accessible :body, :deleted, :name
end