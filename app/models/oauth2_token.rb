class Oauth2Token < AccessToken
  def default_expiry_time
    if self.scope.include?(:offline_access)
      nil
    else
      Time.now + 2.weeks
    end
  end
end
