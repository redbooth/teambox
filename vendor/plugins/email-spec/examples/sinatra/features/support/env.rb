# Sets up the Rails environment for Cucumber
ENV["RACK_ENV"] ||= "test"
require File.expand_path(File.dirname(__FILE__) + '/../../app.rb')

# Comment out the next line if you don't want Cucumber Unicode support
require 'cucumber/formatter/unicode'

require 'rack/test'
require 'webrat'
require 'cucumber/webrat/table_locator' # Lets you do table.diff!(table_at('#my_table').to_a)

Webrat.configure do |config|
  config.mode = :rack
end

require 'webrat/core/matchers'

# email testing in cucumber
require 'activesupport'
require File.expand_path(File.dirname(__FILE__) + '../../../../../lib/email_spec')
require 'email_spec/cucumber'

class AppWorld
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers

  def app
    Sinatra::Application.new
  end
end

World { AppWorld.new }