class Upload < RoleRecord

  ICONS = %w(aac ai aiff avi bmp c cpp css dat dmg doc dotx dwg dxf eps exe flv gif h hpp html ics iso java jpg key mid mp3 mp4 mpg odf ods odt otp ots ott pdf php png ppt psd py qt rar rb rtf sql tga tgz tiff txt wav xls xlsx xml yml zip)
    
  belongs_to :user
  belongs_to :comment
  belongs_to :project
  belongs_to :page
  has_one    :page_slot, :as => :rel_object
  before_destroy :clear_slot

  default_scope :order => 'created_at DESC'

  has_attached_file :asset,
    :styles => { :thumb => "64x48>" },
    :url  => "/assets/:id/:style/:basename.:extension",
    :path => ":rails_root/assets/:id/:style/:filename"

  before_post_process :image?

  validates_attachment_size :asset, :less_than => APP_CONFIG['asset_max_file_size'].to_i.megabytes
  validates_attachment_presence :asset
  
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

  def clear_slot
    page_slot.update_attributes(:page_id => nil) if page and page_slot
  end
  
  def slot_view
    'uploads/upload_slot'
  end

  def to_s
    file_name
  end

  def downloadable?(user)
    true
  end

  def file_type
    ext = File.extname(file_name).sub('.','')
    ext = '...' if ext == ''
    ext
  end
  
  def user
    User.find_with_deleted(user_id)
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.file :id => id do
      xml.tag! 'filename', asset_file_name
      xml.tag! 'description', description
      xml.tag! 'mime-type', asset_content_type
      xml.tag! 'bytes', asset_file_size
      xml.tag! 'download', url
      xml.tag! 'created-at', created_at.to_s(:db)
      xml.tag! 'updated-at', updated_at.to_s(:db)
      xml.tag! 'user-id', user_id
      xml.tag! 'comment-id', comment_id
    end
  end
end