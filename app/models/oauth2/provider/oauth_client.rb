# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

module Oauth2
  module Provider
    class OauthClient < ActiveRecord::Base

      validates_presence_of :name, :redirect_uri
      before_create :generate_keys
      has_many :oauth_tokens, :class_name => "Oauth2::Provider::OauthToken", :dependent => :delete_all
      has_many :oauth_authorizations, :class_name => "Oauth2::Provider::OauthAuthorization", :dependent => :delete_all
      belongs_to :user
      validates_format_of :redirect_uri, :with => Regexp.new("^(https|http)://.+$")

      def create_token_for_user_id(user_id)
        oauth_tokens.create!(:user_id => user_id)
      end
      
      def create_authorization_for_user_id(user_id)
        oauth_authorizations.create!(:user_id => user_id)
      end
      
      def self.model_name
        ActiveSupport::ModelName.new('OauthClient')
      end
      
      private
      def generate_keys
        self.client_id = ActiveSupport::SecureRandom.hex(32)
        self.client_secret = ActiveSupport::SecureRandom.hex(32)
      end
    
    end
  end
end