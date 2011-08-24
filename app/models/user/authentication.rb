class User
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  attr_accessor :current_token
  
  def self.authenticate(login, password)
    unless login.blank? or password.blank?
      u = find_by_username_or_email(login)
      u && u.authenticated?(password) ? u : nil
    end
  end

protected

  def self.generate_email_login_token
    ActiveSupport::SecureRandom.hex(20)
  end

end
