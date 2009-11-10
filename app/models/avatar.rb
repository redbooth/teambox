class Avatar < ActiveRecord::Base
  belongs_to :user
  validates_associated :user
  #after_create :set_width_and_height
  acts_as_fleximage do
    image_directory 'public/avatars'
    use_creation_date_based_directories false
    only_images true
    default_image_path 'public/images/default_avatar.jpg'
    require_image true
    
    preprocess_image do |image|
      image.resize '255x800', :upsample => true
      image.crop :from => '0x0', :size => '255x400'
    end
        
    def set_width_and_height
          path = "#{RAILS_ROOT}/public/avatars/#{id}#{file_extension}"
          w = Magick::ImageList.new(path).columns
          h = Magick::ImageList.new(path).rows
          r = [w,h].max
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