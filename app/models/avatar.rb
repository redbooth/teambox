class Avatar < ActiveRecord::Base
  belongs_to :user
  
  acts_as_fleximage do
    image_directory 'public/avatars'
    use_creation_date_based_directories false
    image_storage_format :jpg
    invalid_image_message 'format is invalid. You must supply a valid image file.'
    require_image true
    default_image_path 'public/images/default_avatar.jpg'
  
    preprocess_image do |image|
      image.resize '255x800', :upsample => true
      image.crop :from => '0x0', :size => '255x400'
    end
    
    def set_width_and_height
      path = "#{RAILS_ROOT}/public/avatars/#{id}.jpg"
      w = Magick::ImageList.new(path).columns
      h = Magick::ImageList.new(path).rows
      w < h ? r = w : r = h
      update_attributes({
        :width => w, 
        :height => h,
        :x1 => 0,
        :x2 => r,
        :y1 => 0,
        :y2 => r,
        :crop_width => r,
        :crop_height => r
      })
    end
    
  end
end  