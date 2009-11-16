class Upload < ActiveRecord::Base
    
  belongs_to :user
  belongs_to :comment
  belongs_to :project

  default_scope :order => 'created_at DESC'

  has_attached_file :upload, 
    :url  => "/uploads/:id/:style/:basename.:extension",
    :path => ":rails_root/uploads/:id/:style/:basename.:extension"

  validates_attachment_size :upload, :less_than => 10.megabytes

  def url(*args)
    upload.url(*args)
  end

  def file_name
    upload_file_name
  end

  def size
    upload_file_size
  end

  def after_create
    self.project.log_activity(self,'create')
  end

  def downloadable?(user)
    true
  end
  
end