if Teambox.config.redis
  $redis = Redis.new(Teambox.config.redis_config)
end
