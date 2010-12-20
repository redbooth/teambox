Teambox::Application.config.middleware.use OmniAuth::Builder do
  Teambox.config.providers.each do |config|
    provider config[:provider].to_sym, config[:key], config[:secret]
  end
end if Teambox.config.providers?
