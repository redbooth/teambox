# Be sure to restart your server when you modify this file.

#Teambox::Application.config.session_store :cookie_store, :key => '_teambox-2_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
#Teambox::Application.config.session_store :active_record_store

#Teambox::Application.config.session_store :redis_session_store, :servers => "redis://secret@127.0.0.1:6999/10",  :expires => seconds, :key_prefix => prefix/namespace to be used
Teambox::Application.config.session_store :redis_session_store, 
  :key_prefix => "_teambox-2_session_",
  #:domain => "#{Teambox::Application.config.app_domain}",
  #:path => "/",
  :httponly => false, #allow access to scripts
  :key => '_teambox-2_session', 
  :secret => Teambox::Application.config.secret_token,
  :expire_after => 60*60*24*7
