class Flexupload < ActiveRecord::Base
  acts_as_fleximage do
    directory 'public/flextest'
    only_images false
  end
end