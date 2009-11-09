ENV['RAILS_ENV'] = RAILS_ENV='selenium'

Webrat.configure do |config|
  config.mode = :selenium
end

Cucumber::Rails::World.use_transactional_fixtures = false

Before do
  
end