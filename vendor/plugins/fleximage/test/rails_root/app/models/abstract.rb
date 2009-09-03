class Abstract < ActiveRecord::Base
  set_table_name :photo_dbs
  
  acts_as_fleximage do
    require_image false
    default_image :size => '320x240', :color => 'red'
  end
end