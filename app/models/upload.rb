class Upload < ActiveRecord::Base

  ICONS = ["aac", "ai", "aiff", "avi", "bmp", "c", "cpp", "css", "dat", "dmg", "doc", "dotx", "dwg", "dxf", "eps", "exe", "flv", "gif", "h", "hpp", "html", "ics", "iso", "java", "jpg", "key", "mid", "mp3", "mp4", "mpg", "odf", "ods", "odt", "otp", "ots", "ott", "pdf", "php", "png", "ppt", "psd", "py", "qt", "rar", "rb", "rtf", "sql", "tga", "tgz", "tiff", "txt", "wav", "xls", "xlsx", "xml", "yml", "zip"]
    
  belongs_to :user
  belongs_to :comment
  belongs_to :project

  default_scope :order => 'created_at DESC'

  has_attached_file :asset,
    :styles => { :thumb => "64x48#" },
    :url  => "/assets/:id/:style/:basename.:extension",
    :path => ":rails_root/assets/:id/:style/:basename.:extension"

  validates_attachment_size :asset, :less_than => 10.megabytes

  def url(*args)
    asset.url(*args)
  end

  def file_name
    asset_file_name
  end

  def size
    asset_file_size
  end

  def after_create
    self.project.log_activity(self,'create')
  end

  def downloadable?(user)
    true
  end
  
  def is_image?
    File.mime_type?(self.asset.path(:original))  == 'image/jpeg'
  end

end