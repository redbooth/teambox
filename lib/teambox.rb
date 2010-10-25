module Teambox
  def self.config
    Rails.configuration
  end

  class Initializer < Rails::Initializer
    def self.run(what = :process, config = Teambox::Configuration.new)
      super(what, config)
    end

    protected

    def process
      super

      unless $gems_rake_task
        initialize_tender_multipass
        setup_amazon_s3
      end
    end

    def load_application_classes
      # Deprecated
      Object.const_set(:APP_CONFIG, Rails.configuration.external)
      super
    end

    private

    def initialize_tender_multipass
      if configuration.tender.site_key
        require 'multipass'
        Teambox.tender_multipass = MultiPass.new(configuration.tender.site_key, configuration.tender.api_key)
      end
    end
    
    def setup_amazon_s3
      if Teambox.config.amazon_s3
        Paperclip::Attachment.default_options.update(
          :storage => :s3,
          :s3_credentials => configuration.amazon_s3_config_file.to_s
        )
      end
    end
  end
  
  class GemLocator < Rails::Plugin::GemLocator
    def plugins
      blocked_names = initializer.configuration.skip_gem_plugins
      super.reject { |plugin| blocked_names.include? plugin.name }
    end
  end

  class Configuration < Rails::Configuration
    def initialize
      super
      self.tender = {}
      self.skip_gem_plugins = []
      self.providers = []
    end
    
    def external
      @choices
    end
    
    def from_file(name)
      super

      if ENV['URL'] and app_domain == 'app.teambox.com'
        self.app_domain = ENV['URL']
      end

      # By default, we'll run on the community mode, but test on the non-community version
      if %w[test cucumber].include? RAILS_ENV
        self.community = false
      elsif !self.respond_to?(:community) or self.community.nil?
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
        action_mailer.smtp_settings = smtp_settings
      end
    end
    
    def amazon_s3_config_file
      Rails.root + 'config/amazon_s3.yml'
    end
    
    def default_plugin_locators
      locators = []
      locators << GemLocator if defined? Gem
      locators << Rails::Plugin::FileSystemLocator
    end
  end

  def self.tender_multipass
    @tender_multipass
  end

  def self.tender_multipass=(multipass)
    @tender_multipass = multipass
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
end
