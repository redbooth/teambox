class User

  AvatarSizes = {
    :micro => [24,24],
    :thumb => [48,48],
    :profile => [278,500] }

  has_attached_file :avatar, 
    :storage => (APP_CONFIG['amazon_s3']['enabled'] ? :s3 : :filesystem),
    :s3_credentials => "#{RAILS_ROOT}/config/amazon_s3.yml",
    :bucket => APP_CONFIG['amazon_s3']["bucket_#{RAILS_ENV}"],
    :url  => "/avatars/:id/:style.png",
    :path => (APP_CONFIG['amazon_s3']['enabled'] ? "avatars/:id/:style.png" : ":rails_root/public/avatars/:id/:style.png"),
    :styles => { 
      :micro => ["#{AvatarSizes[:micro][0]}x#{AvatarSizes[:micro][1]}#", :png], 
      :thumb => ["#{AvatarSizes[:thumb][0]}x#{AvatarSizes[:thumb][1]}#", :png], 
      :profile => ["#{AvatarSizes[:profile][0]}x#{AvatarSizes[:profile][1]}>", :png]
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
      if APP_CONFIG['amazon_s3']['enabled']
        avatar.url(size)
      else
        "http://#{APP_CONFIG['app_domain']}#{avatar.url(size)}"
      end
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