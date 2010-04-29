class User

  AvatarSizes = {
    :micro    => [24, 24],
    :thumb    => [48, 48],
    :profile  => [278, 500]
  }

  has_attached_file :avatar, 
    :url  => "/avatars/:id/:style.png",
    :path => (Teambox.config.amazon_s3 ? "avatars/:id/:style.png" : ":rails_root/public/avatars/:id/:style.png"),
    :styles => AvatarSizes.each_with_object({}) { |(name, size), all|
        all[name] = ["%dx%d%s" % [size[0], size[1], size[0] < size[1] ? '>' : '#'], :png]
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
      url = avatar.url(size)
      url = "http://#{Teambox.config.app_domain}" + url unless url.begins_with? 'http'
      url
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

    def gravatar(size, default='identicon')
      url = "http://www.gravatar.com/avatar/#{gravatar_id}?s=#{AvatarSizes[size][0]}"
      url += "&d=#{default}" if default
      url
    end

end