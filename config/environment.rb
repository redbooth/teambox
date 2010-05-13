require File.expand_path('../boot', __FILE__)
require 'teambox'

Bundler.require(:default, RAILS_ENV)

Teambox::Initializer.run do |config|
  config.load_paths << Rails.root + 'app/sweepers'
  config.active_record.observers = :task_list_panel_sweeper

  config.action_controller.session_store = :active_record_store

  config.action_view.sanitized_allowed_tags = 'table', 'th', 'tr', 'td'

  config.after_initialize do
    SprocketsApplication.use_page_caching = !config.heroku?
    ActiveSupport::XmlMini.backend = 'LibXML'
  end
end

# set default locale (Eglish) to be a fallback for missing translations
I18n.exception_handler = lambda do |e, locale, key, options|
  if I18n::MissingTranslationData === e and locale != I18n.default_locale
    I18n.translate(key, options.update(:locale => I18n.default_locale, :raise => true))
  else
    raise e
  end
end