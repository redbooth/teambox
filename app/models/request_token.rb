class RequestToken < OauthToken

  attr_accessor :provided_oauth_verifier

  def authorize!(user)
    return false if authorized?
    self.user = user
    self.authorized_at = Time.now
    self.verifier=OAuth::Helper.generate_key(20)[0,20]
    self.save
  end

  def exchange!
    return false unless authorized?
    return false unless verifier==provided_oauth_verifier

    RequestToken.transaction do
      access_token = AccessToken.create(:user => user, :client_application => client_application)
      invalidate!
      access_token
    end
  end

  def to_query
    "#{super}&oauth_callback_confirmed=true"
  end

  def oob?
    self.callback_url=='oob'
  end

end
