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

      self.time_zone = @teambox.time_zone
      self.i18n.default_locale = @teambox.default_locale

      self.action_mailer.default_url_options = { :host => @teambox.app_domain }

      if @teambox.allow_outgoing_email
        self.action_mailer.delivery_method = :smtp
        self.action_mailer.smtp_settings = @teambox.smtp_settings
      end
    end

    def heroku?
      @heroku
    end
  end

  def self.tender_multipass
    @tender_multipass
  end

  def self.tender_multipass=(multipass)
    @tender_multipass = multipass
  end
end
