%w{yml rb}.each do |type|
  I18n.load_path += Dir.glob("#{RAILS_ROOT}/app/locales/**/*.#{type}")
end
I18n.default_locale = 'en'
