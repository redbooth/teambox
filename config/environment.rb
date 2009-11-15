RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')

APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/teambox.yml")[RAILS_ENV]

Rails::Initializer.run do |config|
  config.action_controller.session_store = :active_record_store
  config.gem 'haml'
  config.gem 'sprockets'
  config.gem 'completeness-fu'

  config.time_zone = APP_CONFIG['time_zone']

  config.action_mailer.default_url_options = { :host => APP_CONFIG['app_domain'] }

  # Configure and uncomment the following lines for your email server
  #
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   :address        => 'smtp.yourserver.com',
  #   :port           => 25,
  #   :domain         => 'your_desploy_server_app',
  #   :user_name      => 'username',
  #   :password       => 'password',
  #   :authentication => :plain
  # }
  
  require 'RedCloth'
  require 'mime/types'
end
