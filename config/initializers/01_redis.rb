##
# Redis Intro: http://jimneath.org/2011/03/24/using-redis-with-ruby-on-rails.html
#

if %w(staging production).include?(Rails.env)
  config = Rails.root.join("config", "redis.yml")
  redis_config = YAML.load_file(config)
  settings = { :host => redis_config[Rails.env]['host'] }
end

$redis = Redis.new(settings || {})
