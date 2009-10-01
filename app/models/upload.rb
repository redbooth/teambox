class Upload < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment
  belongs_to :project

  default_scope :order => 'created_at DESC'

  ICONS = ["aac", "ai", "aiff", "avi", "bmp", "c", "cpp", "css", "dat", "dmg", "doc", "dotx", "dwg", "dxf", "eps", "exe", "flv", "gif", "h", "hpp", "html", "ics", "iso", "java", "jpg", "key", "mid", "mp3", "mp4", "mpg", "odf", "ods", "odt", "otp", "ots", "ott", "pdf", "php", "png", "ppt", "psd", "py", "qt", "rar", "rb", "rtf", "sql", "tga", "tgz", "tiff", "txt", "wav", "xls", "xlsx", "xml", "yml", "zip"]
  
  
  validates_each :filename do |record, attr, value|
    if record.new_record?
      filename_is_used = Upload.find(:first,:conditions =>
        [ "project_id = ? AND filename = ?",
          record.project_id, value ])
    else
      filename_is_used = Upload.find(:first,:conditions =>
        [ "project_id = ? AND filename = ? AND id != ?",
          record.project_id, value, record.id ])
    end
    
    if filename_is_used
      record.filename = record.unique_filename(value)
    end
  end
  
  acts_as_fleximage do
    directory 'public/upload'
    use_creation_date_based_directories false
    only_images false
    require_file true
  end
  
  def unique_filename(_filename)
    extension_part = File.extname(_filename)
    file_part = _filename[0..-(extension_part.length + 1)]
    
    used = x = 1
    while used != nil
      new_filename = file_part + "_" + x.to_s + extension_part
      used = Upload.find_by_filename(new_filename,:conditions => { :project_id => self.project_id })
      x += 1
    end
    new_filename
  end
  
  def after_create
    self.project.log_activity(self,'create')
  end
end