Teambox::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # RAILS3 investigate
  # config.action_view.cache_template_loading            = true

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
  # RAILS3 check
  # if ENV['MEMCACHE_SERVERS']
  #   # Heroku setup: heroku addons:add memcached
  #   memcache_config = ENV['MEMCACHE_SERVERS'].split(',')
  #   memcache_config << { :namespace => ENV['MEMCACHE_NAMESPACE'] }
  #   config.cache_store = :mem_cache_store, memcache_config
  # else
  #   config.cache_store = :file_store, Rails.root + "tmp/cache"
  # end

  # Specifies the header that your server uses for sending files, Apache version
  # config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'
  #
  # See this gist (https://gist.github.com/559824d94db103d284b0) for how to configure nginx correctly.

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new


  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"
  # RAILS3 loading issue, not really needed
  # config.action_controller.asset_host = AssetHostingWithMinimumSsl.new(
  #   "http://#{Teambox.config.app_domain}", "https://#{Teambox.config.app_domain}"
  # )

  # Disable delivery errors, bad email addresses will be ignored
  config.action_mailer.raise_delivery_errors = false

  # RAILS3 fixme
  # config.action_mailer.delivery_method = :smtp
  
  #RAILS 3 -  When using url_helpers in Mailers you now need to set host in the default url_options
  config.action_mailer.default_url_options = {:host => Teambox.config.app_domain}

  # Enable threaded mode
  # config.threadsafe!

  # RAILS3 check if needed
  # threadsafe settings turns off autoloading; turn it on for rake tasks
  # config.dependency_loading = !!$rails_rake_task

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  # RAILS3 check this and check initializers/locale_fallbacks.rb
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
end
