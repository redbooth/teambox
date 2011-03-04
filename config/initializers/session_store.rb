# Be sure to restart your server when you modify this file.

#Teambox::Application.config.session_store :cookie_store, :key => '_teambox-2_session'


if $redis
  Teambox::Application.config.session_store :redis_session_store, 
    :key_prefix => "_teambox-2_session_",
    :httponly => false, #allow access to scripts
    :key => '_teambox-2_session', 
    :secret => Teambox::Application.config.secret_token,
    :expire_after => 60*60*24*7,
    :servers => {:host => $redis.client.host}
else
  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rails generate session_migration")
  Teambox::Application.config.session_store :active_record_store
end
