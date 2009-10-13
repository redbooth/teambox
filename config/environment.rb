# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  config.action_controller.session_store = :active_record_store

  config.gem 'haml'
  config.gem 'sprockets'
  
  # Install instructions at http://github.com/adzap/ar_mailer/tree/master
  config.gem "adzap-ar_mailer", :lib => 'action_mailer/ar_mailer', :source => 'http://gems.github.com'

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  require 'RedCloth'  
  require 'mime/types'
  config.time_zone = 'UTC'

  config.action_mailer.default_url_options = { :host => 'teambox.com' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address        => 'smtp.gmail.com',
    :port           => 587,
    :domain         => 'teambox.com',
    :user_name      => 'mailer@teambox.com',
    :password       => 'password',
    :authentication => :plain
  }
end
