class Project

  validates_length_of :name, :minimum => 1, :on => :create
  validates_length_of :name, :minimum => 1, :on => :update
  validates_uniqueness_of :permalink, :case_sensitive => false, :scope => :deleted
  validates_length_of :permalink, :minimum => 2
  validates_format_of :permalink, :with => /^[a-z0-9_\-]{2,}$/, :if => :permalink_length_valid?

  # needs an owner
  validates_presence_of :user         # A project _needs_ an owner
  validates_presence_of :organization
  
  def permalink_length_valid?
    permalink.length >= 2
  end
  
  def ensure_organization
    unless user.organization_ids.include?(self.organization_id)
      self.errors.add(:organization_id, "You're not allowed to modify projects in this organization")
    end
  end

end
