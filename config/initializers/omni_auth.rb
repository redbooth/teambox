Teambox::Application.config.middleware.use OmniAuth::Builder do
  Teambox.config.providers.each do |config|
    options = {}
    options[:scope] = config[:scope] if config[:scope]
    provider config[:provider].to_sym, config[:key], config[:secret], options
  end
end if Teambox.config.providers?