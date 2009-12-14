# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'

# Comment out the next line if you don't want Cucumber Unicode support
require 'cucumber/formatter/unicode'

# Comment out the next line if you don't want transactions to
# open/roll back around each scenario
#Cucumber::Rails.use_transactional_fixtures
Cucumber::Rails::World.use_transactional_fixtures = false
require 'capybara/rails'
require 'capybara/cucumber'
Capybara.default_driver = :selenium

require 'cucumber/rails/rspec'


# email testing in cucumber
require File.expand_path(File.dirname(__FILE__) + '../../../../../lib/email_spec')
require 'email_spec/cucumber'

require File.expand_path(File.dirname(__FILE__) +'/../../spec/model_factory.rb')
World(Fixjour)

