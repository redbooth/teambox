class User
  
  validates_presence_of     :login
  validates_length_of       :login,       :within => 3..40
  validates_uniqueness_of   :login,       :case_sensitive => false
  validates_format_of       :login,       :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :first_name,  :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_format_of       :last_name,   :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :first_name,  :within => 1..20
  validates_length_of       :last_name,   :within => 1..20

  validates_presence_of     :email
  validates_length_of       :email,       :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,       :case_sensitive => false
  validates_format_of       :email,       :with => Authentication.email_regex, :message => Authentication.bad_email_message

  validates_associated :projects    # Ensure associated projects exist

  def before_create
    [self.first_name, self.last_name].each { |a| a.capitalize! }
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def short_name
    "#{self.first_name[1,1]}. #{self.last_name}"
  end

end