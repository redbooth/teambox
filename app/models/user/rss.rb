class User
  
  def rss_token
    if read_attribute(:rss_token).nil?
      token = generate_rss_token
      self.update_attribute(:rss_token, token)
      write_attribute(:rss_token, token)
    end
    
    read_attribute(:rss_token)
  end
  
  def self.find_by_rss_token(t)
    token = t.slice!(0..39)
    user_id = t
    User.find_by_rss_token_and_id(token,user_id)
  end
  
  protected
  
    def generate_rss_token
      ActiveSupport::SecureRandom.hex(20)
    end
end