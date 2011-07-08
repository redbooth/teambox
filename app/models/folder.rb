class Folder < RoleRecord
  include Immortal

  belongs_to :user
  belongs_to :project
  belongs_to :parent_folder, :class_name => 'Folder'
  has_many :folders, :foreign_key => :parent_folder_id, :conditions => {:deleted => false}
  has_many :uploads, :foreign_key => :parent_folder_id, :conditions => {:deleted => false}

  # TODO: Validate it has a name, a project and a user

  #after_create  :log_create

  #attr_accessible :asset,
  #                :page_id,
  #                :description
  
  # validate uniqueness of name

  def user
    @user ||= user_id ? User.with_deleted.find_by_id(user_id) : nil
  end

  def to_s
    name
  end

  # TODO: Can also create folders_count column to cache number of child folders for each folder
  def has_children?
    !folders.empty?
  end

  # TODO: Both methods below may be replaced by counter cache columns for better performance
  def folders_count
    folders.count
  end

  def uploads_count
    uploads.count
  end

  def has_parent?
    !parent_folder.nil?
  end

  protected

  def log_create
    save_slot if page
    project.log_activity(self, 'create', user_id) unless comment
  end

end

