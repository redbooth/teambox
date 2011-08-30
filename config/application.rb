require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Teambox

  def self.config
    Rails.configuration
  end

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    config.active_record.observers = :notifications_observer, :threads_observer, :pending_tasks_observer, :cached_fragments_observers

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :rss_token, :access_token]

    # Allowed tags are: a, abbr, acronym, address, b, big, blockquote, br, cite, code, dd, 
    # del, dfn, dl, dt,  em, h1, h2, h3, h4, h5, h6, hr, i, img, ins, kbd, li, ol, p, pre,
    # samp, small, span, strong, sub, sup, table, td, tr, th, tt, ul, var
    config.after_initialize do
      ActionView::Base.sanitized_allowed_tags.delete 'div'
      ActionView::Base.sanitized_allowed_tags = ['table', 'tr', 'td', 'th']
    end

    def config.from_file(file)
      self.skip_gem_plugins = []
      self.providers = []
      self.community = nil
      super

      if ENV['URL'] and app_domain == 'app.teambox.com'
        self.app_domain = ENV['URL']
      end

      # By default, we'll run on the community mode, but test on the non-community version
      if %w[test cucumber].include? Rails.env
        self.community = false
      elsif self.community.nil?
        self.community = true
      end

      self.amazon_s3 = true if heroku?
      self.i18n.default_locale = default_locale
      self.action_mailer.default_url_options = { :host => app_domain }

      if ENV['SENDGRID_PASSWORD'] and
          smtp_settings[:address] == 'smtp.sendgrid.net' and
          smtp_settings[:password] == 'PASSWORD'
          smtp_settings.update(
            :user_name  => ENV['SENDGRID_USERNAME'],
            :password   => ENV['SENDGRID_PASSWORD'],
            :domain     => ENV['SENDGRID_DOMAIN']
          )
        self.allow_outgoing_email = true
      end

      if allow_outgoing_email
        action_mailer.delivery_method = :smtp
        action_mailer.smtp_settings = smtp_settings.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      else
        unless Rails.env.test? || Rails.env.cucumber?
          action_mailer.delivery_method = :test
        end
      end

    end
    config.from_file 'teambox.yml'

    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec, :fixture => false, :views => false
    end

    # Redirect http to https if secure_logins is true
    # https://github.com/tobmatth/rack-ssl-enforcer
    config.middleware.use Rack::SslEnforcer if Teambox.config.secure_logins

  end

  def self.fetch_incoming_email
    if config.allow_incoming_email
      settings = config.incoming_email_settings
      Emailer::Incoming.fetch(settings)
    else
      abort "This application instance isn't set to process incoming email.\n" +
        "Check the 'allow_incoming_email' configuration option"
    end
  end

  Object.const_set(:APP_CONFIG, config)
end
