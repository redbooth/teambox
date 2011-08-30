class Folder < RoleRecord
  include Immortal
  include Tokenized

  belongs_to :user
  belongs_to :project
  belongs_to :parent_folder, :class_name => 'Folder'
  has_many :folders, :foreign_key => :parent_folder_id
  has_many :uploads, :foreign_key => :parent_folder_id

  NAME_LENGTH = 1..40
  NAME_REGEXP = /^[a-z0-9\-_\s\.]+$/i

  validates :name, :project, :user, :presence => true
  validate :validate_unique_name, :on => :create
  validates_format_of :name, :with => NAME_REGEXP
  validates_length_of :name, :within => NAME_LENGTH

  #after_create  :log_create
  attr_accessor :invited_user_email

  def to_s
    name
  end

  # TODO: Can also create folders_count column to cache number of child folders for each folder
  def has_children?
    !folders.empty?
  end

  def has_parent?
    !parent_folder.nil?
  end

  # TODO: Both methods below may be replaced by counter cache columns for better performance
  def folders_count
    folders.count
  end

  def uploads_count
    uploads.count
  end

  def moveable?
    has_parent? or project.folders.where(:parent_folder_id => nil).count > 1
  end

  def send_public_download_email
    return if @is_silent
    Emailer.send_with_language :public_download, user.locale, self.id, self.invited_user_email, 'folder'
  end

  protected

  def validate_unique_name
    if Folder.find_by_project_id_and_name_and_parent_folder_id_and_deleted(project_id, name, parent_folder_id, false)
      errors.add(:name, :taken)
    end
  end

  def log_create
    project.log_activity(self, 'create', user_id)
  end

end

