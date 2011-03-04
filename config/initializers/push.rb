if Teambox.config.push_new_activities
  redis_config = Teambox.config.redis_config || {}

  [:host, :port, :path, :url, :password].each do |key|
    Juggernaut.redis_options[key] = redis_config[key] if redis_config[key]
  end
end
