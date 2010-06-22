# pickle and factory_girl need to load the app so they can inspect models
ENV["RAILS_ENV"] ||= "cucumber"
require File.expand_path('../../../config/environment', __FILE__)

require 'factory_girl'
Factory.find_definitions
require 'pickle/world'

Pickle.configure do |config|
  config.adapters = [:factory_girl]
  # config.map 'I', 'myself', 'me', 'my', :to => 'user: "me"'
end
