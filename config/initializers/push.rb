if Teambox.config.push_new_activities
  Juggernaut.redis_options[:host] = $redis.client.host
end
