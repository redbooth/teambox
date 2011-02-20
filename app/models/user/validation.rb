class User

  RESERVED_USERNAMES = ["all"]

  validates_presence_of     :login
  validates_length_of       :login,       :within => 3..40
  validates_uniqueness_of   :login,       :case_sensitive => false
  validates_format_of       :login,       :with => Authentication.login_regex, :message => I18n.t("users.form.invalid_login")
  validates_exclusion_of    :login,       :in => RESERVED_USERNAMES

  validates_format_of       :first_name,  :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_format_of       :last_name,   :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :first_name,  :within => 1..20
  validates_length_of       :last_name,   :within => 1..20

  validates_length_of       :email,       :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,       :case_sensitive => false
  
  validates                 :email,       :presence => true, :email => { :message => Authentication.bad_email_message }
  validate  :old_password_provided?, :if => lambda { |u| u.password_confirmation.present? and !u.performing_reset }, :on => :update
  
  before_validation :strip_fields
  
  def strip_fields
    [:email, :login, :first_name, :last_name].each {|v| self[v] = (self[v]||'').strip }
  end

  def login=(value)
    write_attribute :login, value.try(:downcase)
  end

  def email=(value)
    write_attribute :email, value.try(:downcase)
  end

  def name
    I18n.t 'common.format_name', :first_name => first_name, :last_name => last_name
  end

  def short_name
     I18n.t 'common.format_name_short', :first_name => first_name, :last_name => last_name, 
                                        :first_name_first_character => first_name.chars.first, 
                                        :last_name_first_character => last_name.chars.first
  end

  def password_required?
    crypted_password.blank? || !password.blank? || performing_reset
  end

  def old_password_provided?
    @errors.add :old_password, 'is required' if old_password.blank? or !authenticated? old_password
  end

end
