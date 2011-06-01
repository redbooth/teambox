class User
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  before_save :ensure_authentication_token

  attr_accessor :current_token
  
  def self.authenticate(login, password)
    unless login.blank? or password.blank?
      u = find_by_username_or_email(login)
      u && u.authenticated?(password) ? u : nil
    end
  end

  #user to authenticate users via redis
  def ensure_authentication_token
    self.authentication_token ||= ActiveSupport::SecureRandom.hex(20)
    @write_auth_token = self.authentication_token_changed?
    true
  end

  def self.select_auth_tokens(assoc)
    connection.select_rows assoc.except(:select).select("users.authentication_token,users.login").to_sql
  end

  def to_auth_token
    attributes.select {|k,v| %w(authentication_token login).include?(k)}.map {|e| e[1]}
  end

end
