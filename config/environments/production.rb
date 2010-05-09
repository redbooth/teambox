# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
if ENV['MEMCACHE_SERVERS']
  # Heroku setup: heroku addons:add memcached
  memcache_config = ENV['MEMCACHE_SERVERS'].split(',')
  memcache_config << { :namespace => ENV['MEMCACHE_NAMESPACE'] }
  config.cache_store = :mem_cache_store, memcache_config
else
  config.cache_store = :file_store, Rails.root + "tmp/cache"
end

# Enable serving of images, stylesheets, and javascripts from an asset server
config.action_controller.asset_host = AssetHostingWithMinimumSsl.new(
  "http://#{Teambox.config.app_domain}", "https://#{Teambox.config.app_domain}"
)

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
config.action_mailer.delivery_method = :smtp

# Enable threaded mode
config.threadsafe!
