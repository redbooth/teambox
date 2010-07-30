class Upload < RoleRecord

  ICONS = %w(aac ai aiff avi bmp c cpp css dat dmg doc dotx dwg dxf eps exe flv gif h hpp html ics iso java jpg key mid mp3 mp4 mpg odf ods odt otp ots ott pdf php png ppt psd py qt rar rb rtf sql tga tgz tiff txt wav xls xlsx xml yml zip)
    
  belongs_to :user
  belongs_to :comment, :touch => true
  belongs_to :project
  belongs_to :page

  has_one        :page_slot, :as => :rel_object
  before_destroy :clear_slot

  before_create :copy_ownership_from_comment

  default_scope :order => 'created_at DESC'

  has_attached_file :asset,
    :styles => { :thumb => "64x48>" },
    :url  => "/assets/:id/:style/:basename.:extension",
    :path => Teambox.config.amazon_s3 ?
      "assets/:id/:style/:filename" :
      ":rails_root/assets/:id/:style/:filename"

  before_post_process :image?
  
  validates_attachment_size :asset, :less_than => Teambox.config.asset_max_file_size.to_i.megabytes
  validates_attachment_presence :asset
  
  def image?
    !(asset_content_type =~ /^image.*/).nil?
  end

  def url(*args)
    u = asset.url(*args)
    u = u.sub(/\.$/,'')
    u
  end

  def file_name
    asset_file_name
  end

  def size
    asset_file_size
  end

  # TODO: handle truncating of description in views
  include ActionView::Helpers::TextHelper

  def description
    self[:description] || (comment ? truncate(comment.body, :length => 80) : nil)
  end

  def clear_slot
    page_slot.destroy if page_slot
  end
  
  def slot_view
    'uploads/upload_slot'
  end

  def after_create
    project.log_activity(self, 'create', user_id) if page_id
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
      xml.tag! 'page-id', page_id
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
  
  def to_api_hash(options = {})
    {
      :id => id,
      :page_id => page_id,
      :slot_id => page_slot ? page_slot.id : nil,
      :filename => asset_file_name,
      :description => description,
      :mime_type => asset_content_type,
      :bytes => asset_file_size,
      :download => url,
      :created_at => created_at.to_s(:db),
      :updated_at => updated_at.to_s(:db),
      :user_id => user_id,
      :comment_id => comment_id
    }
  end
  
  def to_json(options = {})
    to_api_hash(options).to_json
  end
  
  protected
  
  def copy_ownership_from_comment
    if comment_id
      self.user_id = comment.user_id
      self.project_id = comment.project_id
    end
  end
  
end