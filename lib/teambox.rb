module Teambox
  def self.config
    Rails.configuration.teambox
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
      Object.const_set(:APP_CONFIG, Teambox.config)
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
          :s3_credentials => configuration.amazon_s3_config_file
        )
      end
    end
  end

  class Configuration < Rails::Configuration
    attr_reader :teambox, :tender
    attr_writer :heroku

    def initialize
      super
      @teambox = Rails::OrderedOptions.new
      @tender = Rails::OrderedOptions.new
      @heroku = !!ENV['HEROKU_TYPE']

      YAML.load_file(Rails.root + 'config/teambox.yml')[RAILS_ENV].each do |key, value|
        @teambox[key] = value
      end

      if ENV['URL'] and @teambox.app_domain == 'app.teambox.com'
        @teambox.app_domain = ENV['URL']
      end

      @teambox.amazon_s3 = true if heroku?

      self.time_zone = @teambox.time_zone
      self.i18n.default_locale = @teambox.default_locale

      self.action_mailer.default_url_options = { :host => @teambox.app_domain }

      if ENV['SENDGRID_PASSWORD'] and
          @teambox.smtp_settings[:address] == 'smtp.sendgrid.net' and
          @teambox.smtp_settings[:password] == 'PASSWORD'
        @teambox.smtp_settings.update(
          :user_name  => ENV['SENDGRID_USERNAME'],
          :password   => ENV['SENDGRID_PASSWORD'],
          :domain     => ENV['SENDGRID_DOMAIN']
        )
      end

      if @teambox.allow_outgoing_email
        self.action_mailer.delivery_method = :smtp
        self.action_mailer.smtp_settings = @teambox.smtp_settings
      end
    end

    def heroku?
      @heroku
    end
    
    def amazon_s3_config_file
      "#{Rails.root}/config/amazon_s3.yml"
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
