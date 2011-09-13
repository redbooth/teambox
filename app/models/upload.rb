class Upload < RoleRecord
  include Immortal
  include PrivateElementMethods
  include Tokenized

  ICONS = %w(aac ai aiff avi bmp c cpp css dat dmg doc docx dotx dwg dxf eps exe flv gif h hpp html ics iso java jpg key mid mp3 mp4 mpg odf ods odt otp ots ott pdf php png ppt pptx psd py qt rar rb rtf sql tga tgz tiff txt wav xls xlsx xml yml zip)
    
  belongs_to :user
  belongs_to :comment, :touch => true, :counter_cache => true
  belongs_to :project
  belongs_to :page
  belongs_to :parent_folder, :class_name => 'Folder'

  has_one        :page_slot, :as => :rel_object
  before_destroy :clear_slot
  before_destroy :update_comment_to_show_delete
  after_destroy  :cleanup_activities

  before_create :copy_ownership_from_comment
  after_create  :log_create
  before_save   :inherit_privacy

  attr_accessible :asset,
                  :page_id,
                  :description,
                  :parent_folder_id,
                  :asset_file_name
                
  attr_accessor :invited_user_email

                
  include PageWidget

  DOWNLOADS_URL = "/downloads/:id/:style/:basename.:extension"

  has_attached_file :asset,
    :styles => { :thumb => "150x150>", :small => "250x250>"},
    :url  => DOWNLOADS_URL,
    :path => Teambox.config.amazon_s3 ?
      "assets/:id/:style/:filename" :
      ":rails_root/assets/:id/:style/:filename",
    :s3_permissions => 'private',
    :s3_headers => {'Cache-Control' => 'max-age=157680000'}

  before_post_process :image?
  
  validates_attachment_size :asset, 
                            :less_than => Teambox.config.asset_max_file_size.to_i.megabytes, 
                            :message => I18n.t('uploads.form.max_size', 
                                               :mb => Teambox.config.asset_max_file_size.to_i)

  validates_format_of :asset_file_name, :with => /^[^\/]+$/, 
    :allow_blank => false, :message => "Invalid filename"
  validates_format_of :invited_user_email, :with => /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i, :allow_nil => true
  validates_attachment_presence :asset, :message => I18n.t('uploads.form.presence')

  validate :check_page

  def check_page
    if page && (page.project_id != project_id)
      @errors.add :project, 'is not valid'
    end
  end
  
  def image?
    !(asset_content_type =~ /^image(?!.*photoshop.*)/).nil?
  end

  def url(style_name = nil, use_timestamp = false)
    url = asset.original_filename.nil? ? Paperclip::Interpolations.interpolate(@default_url, asset, style_name) : Paperclip::Interpolations.interpolate(DOWNLOADS_URL, asset, style_name)
    url = URI.escape(url)
    use_timestamp && asset.updated_at ? [url, asset.updated_at].compact.join(url.include?("?") ? "&" : "?") : url
  end

  def s3_url(style_name = nil)
    AWS::S3::S3Object.url_for(asset.path(style_name), asset.bucket_name, {:expires_in => Teambox.config.amazon_s3_expiration.to_i})
  end
  
  def rename_asset(new_file_name)
    styles = [:original] + self.asset.styles.keys
    original_paths = Hash[styles.map do |style|
      if self.asset.exists?(style)
        [style, self.asset.path(style)]
       end 
    end.compact]
    
    if original_paths.empty?
      self.errors.add(:base, "Cannot rename asset: no files found")
      false
    elsif !self.update_attributes(:asset_file_name => new_file_name)
      false
    else
      original_paths.each do |style, old_path|
        new_path = File.join(File.dirname(old_path), new_file_name)
        if Teambox.config.amazon_s3
          AWS::S3::S3Object.rename(old_path, new_path, self.asset.bucket_name)
        else
          FileUtils.mv(old_path, new_path)    
        end
      end
      true
    end
  rescue Errno::ENOENT, AWS::S3::S3Exception => exc
    self.errors.add(:base, "Error renaming asset: [#{exc.class.name}] #{exc}")
    false
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
  
  def slot_view
    'uploads/upload_slot'
  end

  def log_create
    save_slot if page
    project.log_activity(self, 'create', user_id) unless comment
  end

  def cleanup_activities
    unless self.comment
      Activity.destroy_all :target_type => self.class.name, :target_id => self.id
    end
  end
  
  def to_s
    file_name
  end

  def moveable?
    parent_folder or !project.folders.where(:parent_folder_id => nil).empty?
  end

  def downloadable?(user)
    project.user_ids.include?(user.id) &&
    user_can_access_private_target?(user)
  end

  def file_type
    ext = File.extname(file_name).sub('.','')
    ext = '...' if ext == ''
    ext
  end
  
  def user
    @user ||= user_id ? User.with_deleted.find_by_id(user_id) : nil
  end
  
  def references
    refs = { :users => [user_id], :projects => [project_id] }
    refs[:comment] = [comment_id] if comment_id
    if page_id
      refs[:page] = [page_id]
      refs[:page_slot] = [page_slot.id] if page_slot
    end
    refs
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
    base = {
      :id => id,
      :page_id => page_id,
      :project_id => project_id,
      :slot_id => page_slot ? page_slot.id : nil,
      :filename => asset_file_name,
      :description => description,
      :mime_type => asset_content_type,
      :bytes => asset_file_size,
      :download => url,
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:api_time),
      :user_id => user_id,
      :comment_id => comment_id,
      :is_private => is_private
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    base
  end

  def send_public_download_email
    return if @is_silent
    Emailer.send_with_language :public_download, user.locale, self.id, self.invited_user_email, 'upload'
  end

  protected
  def copy_ownership_from_comment
    if comment_id
      self.user_id = comment.user_id
      self.project_id = comment.project_id
      self.is_private = comment.is_private
    end
    true
  end

  def inherit_privacy # before_save
    if comment_id
      self.is_private = comment.is_private
    end
    true
  end

  def update_comment_to_show_delete
    if self.comment && self.comment.body.blank? && self.comment.uploads.count == 1
      self.comment.update_attributes(:body => "File deleted")
    end
    true
  end
end
