I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)

# people speaking Catalan also speak Spanish as spoken in Spain
I18n.fallbacks.map(:ca => :es)
