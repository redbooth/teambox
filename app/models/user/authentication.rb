class User
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  def self.authenticate(login, password)
    unless login.blank? or password.blank?
      if login.include? '@' # usernames are not allowed to contain '@'
        u = find_by_email(login.downcase)
      else
        u = find_by_login(login.downcase)
      end
      u && u.authenticated?(password) ? u : nil
    end
  end

end