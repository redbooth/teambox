class User
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  def self.authenticate(login, password)
    unless login.blank? or password.blank?
      u = find_by_username_or_email(login)
      u && u.authenticated?(password) ? u : nil
    end
  end

end