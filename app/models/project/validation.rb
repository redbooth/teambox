class Project

  validates_length_of :name, :minimum => 5, :on => :create  # New projects
  validates_length_of :name, :minimum => 5, :on => :update, :if => :name_changed?  # Changing the name
  validates_length_of :name, :minimum => 3, :on => :update  # Legacy validation for existing projects
  validates_uniqueness_of :permalink, :case_sensitive => false, :scope => :deleted
  validates_length_of :permalink, :minimum => 5
  validates_format_of :permalink, :with => /^[a-z0-9_\-]{5,}$/, :if => :permalink_length_valid?

  # needs an owner
  validates_presence_of :user         # A project _needs_ an owner
  validates_presence_of :organization
  
  def permalink_length_valid?
    permalink.length >= 5
  end
  
  def ensure_organization
    unless user.organization_ids.include?(self.organization_id)
      self.errors.add(:organization_id, "You're not allowed to modify projects in this organization")
    end
  end

end