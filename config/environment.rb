require File.expand_path('../boot', __FILE__)
require 'teambox'

Bundler.require(:default, RAILS_ENV)

Teambox::Initializer.run do |config|
  config.action_view.sanitized_allowed_tags = 'table', 'th', 'tr', 'td', 'iframe'

  config.after_initialize do
    ActionView::Base.sanitized_allowed_tags.delete 'div'
    SprocketsApplication.use_page_caching = !config.heroku?
    ActiveSupport::XmlMini.backend = 'LibXML'
  end
  
  config.active_record.observers = :notifications_observer, :threads_observer
end
