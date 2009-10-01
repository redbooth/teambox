class PhotoCustomError < ActiveRecord::Base
  set_table_name :photo_dbs
  acts_as_fleximage do
    image_directory 'public/uploads'
    validates_image_size '2x2'
    missing_image_message "needs to be attached"
    invalid_image_message "seems to be broken"
    image_too_small_message "must be bigger (min. size: {{minimum}})"
  end
end
