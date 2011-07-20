class Project

  scope :archived, :conditions => {:archived => true}
  scope :unarchived, :conditions => {:archived => false}
  
  def archive!
    update_attribute(:archived, true)
  end
  
end