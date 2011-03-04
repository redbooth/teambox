require 'yaml'
rails_root = (defined?(Rails) && Rails.root) || ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = (defined?(Rails) && Rails.env) || ENV['RAILS_ENV'] || 'development'

if rails_env == 'production' or rails_env == 'staging'
  redis_config = YAML.load_file(rails_root.to_s + '/config/database.yml')
  $redis = Redis.new(:host => redis_config[rails_env]['host'])
else
  $redis = Redis.new
end

