Teambox::Application.configure do
  # Retain code on the server
  config.cache_classes = true

  # Full error reports are disabled and caching is turned off
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  config.serve_static_assets = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = {:host => Teambox.config.app_domain}
  
  config.active_support.deprecation = :notify
end
