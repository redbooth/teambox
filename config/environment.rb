require File.expand_path('../boot', __FILE__)

Bundler.require(:default, RAILS_ENV)

require 'teambox'

Teambox::Initializer.run do |config|
  config.from_file 'teambox.yml'
  
  config.action_view.sanitized_allowed_tags = 'table', 'th', 'tr', 'td'

  config.after_initialize do
    ActionView::Base.sanitized_allowed_tags.delete 'div'
    SprocketsApplication.use_page_caching = !config.heroku?
    ActiveSupport::XmlMini.backend = 'LibXML'
  end
  
  config.active_record.observers = :notifications_observer, :threads_observer
  
  config.skip_gem_plugins << 'thinking-sphinx'
end
