RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')

DEFAULT_HOST   = "www.myhost.dev"
DEFAULT_SECRET = "46ef9bf493d1ae37a5b69e6acb8753ab67876361eb9f7e84fc0308cabdc74934d401a07d3eed715497f0239580552e024ba5b59804da2f1002fa908f304c7b07"

Rails::Initializer.run do |config|
  config.action_controller.session_store = :active_record_store
  config.gem 'haml'
  config.gem 'sprockets'
  config.gem 'completeness-fu'
  config.time_zone = 'UTC'
  config.action_mailer.default_url_options = { :host => 'app.teambox.com' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address        => 'smtp.yourserver.com',
    :port           => 25,
    :domain         => 'your_desploy_server_app',
    :user_name      => 'username',
    :password       => 'password',
    :authentication => :plain
  }
  
  require 'RedCloth'
  require 'mime/types'
end
