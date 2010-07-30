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

  attr_accessible :avatar, :avatar_destroy

  #validates_attachment_presence :avatar, :unless => Proc.new { |user| user.new_record? }
  validates_attachment_size :avatar, :less_than => 2.megabytes
  validates_attachment_content_type :avatar,
    :content_type => %w[image/jpeg image/pjpeg image/png image/x-png image/gif]
  
  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end
  
  def avatar_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
  end

  def avatar_or_gravatar_path(size, secure = false)
    avatar?? avatar.url(size) : gravatar(size, secure)
  end
  
  def avatar_or_gravatar_url(size = :thumb, secure = false)
    avatar_or_gravatar_path(size, secure).tap do |url|
      unless url.starts_with? 'http'
        scheme = secure ? 'https:' : 'http:'
        url.replace '%s//%s%s' % [scheme, Teambox.config.app_domain, url]
      end
    end
  end
  
  def avatar_destroy
    false
  end
  
  def avatar_destroy=(value)
    self.avatar = nil if value and value != '0'
  end

  private

    def gravatar_id
      Digest::MD5.hexdigest email.downcase
    end

    def gravatar(size, secure = false, default = Teambox.config.gravatar_default)
      (secure ? 'https://secure.' : 'http://www.').tap do |url|
        url << "gravatar.com/avatar/#{gravatar_id}?size=#{AvatarSizes[size][0]}"
        url << "&default=#{default}" if default
      end
    end

end