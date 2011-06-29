if Teambox.config.push_new_activities
  Juggernaut.options[:host] = $redis.client.host
end
