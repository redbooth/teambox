class Group
  validates_attachment_size :logo, :less_than => 10.megabytes, :if => :has_logo?

  validates_presence_of :user
  validates_uniqueness_of :permalink, :case_sensitive => false
  validates_length_of :name, :minimum => 3
  validates_length_of :permalink, :minimum => 5
  validates_format_of :permalink, :with => /^[a-z0-9_\-]{5,}$/, :if => :permalink_length_valid?

  def permalink_length_valid?
    (self.permalink || "").length >= 5
  end
end