require "lib/i18n_interpolation_fallbacks"


I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n::Backend::Simple.send(:include, I18n::Backend::MissingInterpolationFallbacks)

# people speaking Catalan also speak Spanish as spoken in Spain
I18n.fallbacks.map(:ca => :es)
