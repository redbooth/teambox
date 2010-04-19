require File.expand_path('../boot', __FILE__)

Bundler.require(:default, RAILS_ENV)

APP_CONFIG = YAML.load_file(RAILS_ROOT + '/config/teambox.yml')[RAILS_ENV]

Rails::Initializer.run do |config|
  config.load_paths << Rails.root + 'app/sweepers'
  config.action_controller.session_store = :active_record_store

  config.action_view.sanitized_allowed_tags = 'table', 'th', 'tr', 'td'
  config.time_zone = APP_CONFIG['time_zone']
  config.i18n.default_locale = :en
  config.action_mailer.default_url_options = { :host => APP_CONFIG['app_domain'] }

  if APP_CONFIG['allow_outgoing_email']
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
     :enable_starttls_auto  => APP_CONFIG['outgoing']['enable_starttls_auto'],
     :address               => APP_CONFIG['outgoing']['host'],
     :port                  => APP_CONFIG['outgoing']['port'],
     :domain                => APP_CONFIG['outgoing']['from'],
     :user_name             => APP_CONFIG['outgoing']['user'],
     :password              => APP_CONFIG['outgoing']['pass'],
     :authentication        => APP_CONFIG['outgoing']['auth'].to_sym
    }
  end

  config.active_record.observers = :task_list_panel_sweeper
  
  config.after_initialize do
    require 'haml/helpers/action_view_mods'
    require 'haml/helpers/action_view_extensions'
    require 'haml/template'
    require 'sass'
    require 'sass/plugin'
    Sass::Plugin.options[:template_location] = { 'app/styles' => 'public/stylesheets' }
    require 'sprockets_controller'
    SprocketsController.caches_page(:index)
    SprocketsApplication.use_page_caching = true
    ActiveSupport::XmlMini.backend = 'LibXML'
  end
end
