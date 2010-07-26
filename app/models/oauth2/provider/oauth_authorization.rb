# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

module Oauth2
  module Provider
    class OauthAuthorization < ::ActiveRecord::Base

      belongs_to :oauth_client, :class_name => "Oauth2::Provider::OauthClient"
  
      EXPIRY_TIME = 1.hour
  
      def generate_access_token
        token = oauth_client.create_token_for_user_id(user_id)
        self.delete
        token
      end
  
      def expires_in
        (Time.at(expires_at.to_i) - Clock.now).to_i
      end
  
      def expired?
        expires_in <= 0
      end
  
      protected
      def before_create
        self.expires_at = Clock.now + EXPIRY_TIME
        self.code = ActiveSupport::SecureRandom.hex(32)
      end
  
    end
  end
end