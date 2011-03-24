class Oauth2Token < AccessToken
  def as_json(options={})
    base = {:access_token=>token}
    base[:expires_in] = expires_in if valid_to
    base[:scope] = scope ? scope.join(' ') : ''
    base
  end
  
  def to_fragment_params(options={})
    as_json(options).map{|k,v| "#{k}=#{CGI::escape(v.to_s)}"}.join('&')
  end
  
  def default_expiry_time
    if self.scope.include?(:offline_access)
      nil
    else
      Time.now + 2.weeks
    end
  end
end
