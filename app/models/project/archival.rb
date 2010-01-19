class Project

  named_scope :archived, :conditions => {:archived => true}
  named_scope :unarchived, :conditions => {:archived => false}
  
  def archive!
    update_attribute(:archived, true)
  end
  
end