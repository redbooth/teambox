if Rails.env == 'production' or Rails.env == 'staging'
  $redis = Redis.new(Teambox.config.redis_config)
else
  $redis = Redis.new
end
