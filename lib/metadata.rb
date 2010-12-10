module Metadata

  module Defaults
    def default_settings
      @default_settings ||= {}
    end

    def default_settings=(data={})
      @default_settings = data
    end
  end

  def settings=(data={})
    write_attribute(:settings, settings.dup.deep_merge(data).to_json)
  end

  def settings
    ActiveSupport::JSON.decode(read_attribute(:settings)) || self.class.default_settings rescue self.class.default_settings
  end
end
