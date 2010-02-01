config.cache_classes = true
config.whiny_nils = true
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true
config.action_controller.allow_forgery_protection    = false
config.action_mailer.delivery_method = :test

config.gem 'rspec',       :lib => false, :version => '>=1.2.8' unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec'))
config.gem 'rspec-rails', :lib => false, :version => '>=1.2.7.1' unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec-rails'))

config.gem "factory_girl", :version => ">= 1.2.3", :source => "http://gemcutter.org"
config.gem "pickle", :version => ">= 0.2.1", :source => "http://gemcutter.org"
