RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')

APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/teambox.yml")[RAILS_ENV]

Rails::Initializer.run do |config|
  config.action_controller.session_store = :active_record_store
  config.gem 'haml'
  config.gem 'sprockets'
  config.gem 'completeness-fu'
  config.gem 'system_timer'
  config.gem 'whenever', :lib => false, :source => 'http://gemcutter.org/'

  config.time_zone = APP_CONFIG['time_zone']

  config.i18n.default_locale = :en

  config.action_mailer.default_url_options = { :host => APP_CONFIG['app_domain'] }

  if APP_CONFIG['allow_outgoing_email']
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
     :address        => APP_CONFIG['outgoing']['host'],
     :port           => APP_CONFIG['outgoing']['port'],
     :domain         => APP_CONFIG['outgoing']['from'],
     :user_name      => APP_CONFIG['outgoing']['user'],
     :password       => APP_CONFIG['outgoing']['pass'],
     :authentication => APP_CONFIG['outgoing']['auth'].to_sym
    }
  end
  
  require 'RedCloth'
  require 'mime/types'
end

# Optional gems to enhance XML performance. Feel free to disable them.
ActiveSupport::XmlMini.backend = 'LibXML'
