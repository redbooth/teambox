Rails.configuration.middleware.use OmniAuth::Builder do
  Teambox.config.providers.each do |config|
    provider config[:provider].to_sym, config[:key], config[:secret] unless config[:provider] == 'google_docs'
  end
end if Teambox.config.providers