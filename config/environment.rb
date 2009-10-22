# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

DEFAULT_HOST   = "sandbox.teambox.com"
DEFAULT_SECRET = "46ef9bf493d1ae37a5b69e6acb8753ab67876361eb9f7e84fc0308cabdc74934d401a07d3eed715497f0239580552e024ba5b59804da2f1002fa908f304c7b07"

Rails::Initializer.run do |config|
  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  config.action_controller.session_store = :active_record_store

  config.gem 'haml'
  config.gem 'sprockets'
  config.gem 'completeness-fu'
  config.gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'
  config.gem 'rspec-rails', :lib => false 
  config.gem 'rspec', :lib => false 
  config.gem 'cucumber' 
  config.gem 'webrat'
  config.gem "adzap-ar_mailer", :lib => 'action_mailer/ar_mailer', :source => 'http://gems.github.com'
  
  require 'RedCloth'  
  require 'mime/types'
  
  config.time_zone = 'UTC'

  config.action_mailer.default_url_options = { :host => 'sandbox.teambox.com' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => 25,
    :domain         => 'teamboxapp.com',
    :user_name      => 'notifications@teamboxapp.com',
    :password       => 'kickME55',
    :authentication => :plain
  }
  
  secret = APP_CONFIG[:action_controller][:session][:secret] rescue DEFAULT_SECRET

  config.action_controller.session = { :session_key => '_teambox_session', :secret => secret }
end

# use this domain for cookies so switching networks doesn't drop cookies
ActionController::Base.session_options[:domain] = DEFAULT_HOST
