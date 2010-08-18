class Project

  validates_length_of :name, :minimum => 5, :on => :create  # New projects
  validates_length_of :name, :minimum => 5, :on => :update, :if => :name_changed?  # Changing the name
  validates_length_of :name, :minimum => 3, :on => :update  # Legacy validation for existing projects
  validates_uniqueness_of :permalink, :case_sensitive => false
  validates_length_of :permalink, :minimum => APP_CONFIG['project_permalink_min_length']
  validates_format_of :permalink, :with => /^[a-z0-9_\-]{#{APP_CONFIG['project_permalink_min_length']},}$/, :if => :permalink_length_valid?

  # needs an owner
  validates_presence_of :user         # A project _needs_ an owner
  validates_presence_of :organization
  
  def permalink_length_valid?
    self.permalink.length >= APP_CONFIG['project_permalink_min_length']
  end

end