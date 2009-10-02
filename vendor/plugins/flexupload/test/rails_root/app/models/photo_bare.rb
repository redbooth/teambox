class PhotoBare < ActiveRecord::Base
  acts_as_fleximage do
    image_directory 'public/uploads'
    validates_image_size '2x2'
  end
end
