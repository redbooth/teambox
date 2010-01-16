class User

  AvatarSizes = {
    :micro => [24,24],
    :thumb => [48,48],
    :profile => [278,500] }

  has_attached_file :avatar, 
    :url  => "/avatars/:id/:style.png",
    :path => ":rails_root/public/avatars/:id/:style.png",
    :styles => { 
      :micro => "#{AvatarSizes[:micro][0]}x#{AvatarSizes[:micro][1]}#", 
      :thumb => "#{AvatarSizes[:thumb][0]}x#{AvatarSizes[:thumb][1]}#", 
      :profile => "#{AvatarSizes[:profile][0]}x#{AvatarSizes[:profile][1]}>" },
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

  def avatar_or_gravatar_url(size)
    if avatar_file_name
      avatar.url(size)
    else
      gravatar(size)
    end
  end

  private
  
    def reprocess_avatar
      avatar.reprocess!
    end

    def gravatar_email
      email.downcase
    end

    def gravatar_id
      Digest::MD5.hexdigest(gravatar_email)
    end

    def gravatar(size, default='wavatar')
      url = "http://www.gravatar.com/avatar/#{gravatar_id}?s=#{AvatarSizes[size][0]}"
      url += "&d=#{default}" if default
      url
    end

end