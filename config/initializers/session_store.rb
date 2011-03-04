# Be sure to restart your server when you modify this file.

#Teambox::Application.config.session_store :cookie_store, :key => '_teambox-2_session'


if Teambox.config.redis
  servers = "redis://localhost:6379/0"

  if Teambox.config.redis_config[:url]
    servers = Teambox.config.redis_config[:url]
  else
    servers = Teambox.config.redis_config
  end

  Teambox::Application.config.session_store :redis_session_store, 
    :key_prefix => "_teambox-2_session_",
    #:domain => "#{Teambox::Application.config.app_domain}",
    #:path => "/",
    :httponly => false, #allow access to scripts
    :key => '_teambox-2_session', 
    :secret => Teambox::Application.config.secret_token,
    :expire_after => 60*60*24*7,
    :servers => servers
else
  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rails generate session_migration")
  Teambox::Application.config.session_store :active_record_store
end
