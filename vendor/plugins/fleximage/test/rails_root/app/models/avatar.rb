class Avatar < ActiveRecord::Base
  acts_as_fleximage :image_directory => 'public/uploads'
  validates_presence_of :username
end
