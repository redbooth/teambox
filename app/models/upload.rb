class Upload < ActiveRecord::Base
  belongs_to :user
  
  acts_as_fleximage do
    image_directory 'public/uploads'
    use_creation_date_based_directories false
    invalid_image_message 'format is invalid. You must supply a valid image file.'
    require_image false
    default_image_path 'public/images/person.gif'
    
  end
end