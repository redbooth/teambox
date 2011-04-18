if Rails.env.development? and ENV['VCR']
  require 'vcr_remote_controller'
  Rails.configuration.middleware.use Rack::VcrRemoteController
end