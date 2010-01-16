class User

  has_attached_file :avatar, 
    :url  => "/avatars/:id/:style.png",
    :path => ":rails_root/public/avatars/:id/:style.png",
    :styles => { 
      :micro => "24x24#", 
      :thumb => "48x48#", 
      :profile => "278x500>" },
    :convert_options => {
      :all => "-define png:bit-depth=24 -interlace PNG"
    }

  #validates_attachment_presence :avatar, :unless => Proc.new { |user| user.new_record? }
  validates_attachment_size :avatar, :less_than => 2.megabytes
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  
  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end
  
  def avatar_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
  end

  private
  
    def reprocess_avatar
      avatar.reprocess!
    end    

end