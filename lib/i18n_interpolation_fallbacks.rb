module I18n
  module Backend
    module MissingInterpolationFallbacks

      def translate(locale, key, options = {})
        super
      rescue I18n::MissingInterpolationArgument
        return super(I18n.config.default_locale,key,options)
      end

    end
  end
end
