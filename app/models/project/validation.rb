class Project

  validates_length_of :name, :minimum => 3
  validates_uniqueness_of :permalink, :case_sensitive => false
  validates_length_of :permalink, :minimum => 5
  validates_format_of :permalink, :with => /^[a-z0-9_\-]{5,}$/, :if => :permalink_length_valid?

  # needs an owner
  validates_presence_of :user         # A project _needs_ an owner
  
  def permalink_length_valid?
    self.permalink.length >= 5
  end

end