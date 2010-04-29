require File.expand_path('../boot', __FILE__)
require 'teambox'

Bundler.require(:default, RAILS_ENV)

Teambox::Initializer.run do |config|
  config.load_paths << Rails.root + 'app/sweepers'
  config.active_record.observers = :task_list_panel_sweeper

  config.action_controller.session_store = :active_record_store

  config.action_view.sanitized_allowed_tags = 'table', 'th', 'tr', 'td'

  config.after_initialize do
    require 'sprockets_controller'
    SprocketsController.caches_page(:index)
    SprocketsApplication.use_page_caching = true
    ActiveSupport::XmlMini.backend = 'LibXML'
  end
end
