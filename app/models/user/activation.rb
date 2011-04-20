class User

  attr_accessor :performing_reset

  def send_activation_email
    self.generate_login_code!
    Emailer.send_email :confirm_email, self.id
  end

  def send_reset_password
    self.generate_login_code!
    Emailer.send_email :reset_password, self.id
  end

  def is_active?
    Teambox.config.email_confirmation_require ? self.confirmed_user : true
  end

  def activate!
    self.confirmed_user = true
    self.save!
    self
  end
  
  def generate_login_code!
    self.login_token = ActiveSupport::SecureRandom.hex(20)
    self.login_token_expires_at = 1.month.from_now
    self.save(:validate => false)
  end
  
  def expire_login_code!
    self.login_token_expires_at = 1.minute.ago
    self.save!
  end
  
  def is_login_token_valid?(token)
    (token == self.login_token) and (self.login_token_expires_at > Time.now)
  end
  
end
