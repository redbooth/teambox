class Upload < RoleRecord


  ICONS = ["aac", "ai", "aiff", "avi", "bmp", "c", "cpp", "css", "dat", "dmg", "doc", "dotx", "dwg", "dxf", "eps", "exe", "flv", "gif", "h", "hpp", "html", "ics", "iso", "java", "jpg", "key", "mid", "mp3", "mp4", "mpg", "odf", "ods", "odt", "otp", "ots", "ott", "pdf", "php", "png", "ppt", "psd", "py", "qt", "rar", "rb", "rtf", "sql", "tga", "tgz", "tiff", "txt", "wav", "xls", "xlsx", "xml", "yml", "zip"]
    
  belongs_to :user
  belongs_to :comment
  belongs_to :project

  default_scope :order => 'created_at DESC'

  has_attached_file :asset,
    :styles => { :thumb => "64x48#" },
    :url  => "/assets/:id/:style/:basename.:extension",
    :path => ":rails_root/assets/:id/:style/:filename"

  before_post_process :image?

  validates_attachment_size :asset, :less_than => 10.megabytes

  def image?
    !(asset_content_type =~ /^image.*/).nil?
  end

  def url(*args)
    u = asset.url(*args)
    u = u.sub(/\.$/,'')
    'http://' + APP_CONFIG['app_domain'] + u
  end

  def file_name
    asset_file_name
  end

  def size
    asset_file_size
  end


  def downloadable?(user)
    true
  end
  
  def file_type
    ext = File.extname(file_name).sub('.','')
    ext = '...' if ext == ''
    ext
  end
  
end