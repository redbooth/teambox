class Project

  validates_length_of :name, :minimum => 3
  validates_uniqueness_of :permalink, :case_sensitive => false
  validates_length_of :permalink, :minimum => APP_CONFIG['project_permalink_min_length']
  validates_format_of :permalink, :with => /^[a-z0-9_\-]{#{APP_CONFIG['project_permalink_min_length']},}$/, :if => :permalink_length_valid?

  # needs an owner
  validates_presence_of :user         # A project _needs_ an owner
  
  def permalink_length_valid?
    self.permalink.length >= APP_CONFIG['project_permalink_min_length']
  end

end
