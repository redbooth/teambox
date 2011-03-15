require 'oauth/controllers/provider_controller'
class OauthController < ApplicationController
  skip_before_filter :login_required
  include OAuth::Controllers::ProviderController
end
