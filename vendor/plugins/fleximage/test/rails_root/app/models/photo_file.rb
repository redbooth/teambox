class PhotoFile < ActiveRecord::Base
  acts_as_fleximage :image_directory => 'public/uploads'
end
