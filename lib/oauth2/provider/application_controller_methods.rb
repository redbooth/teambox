# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

module Oauth2
  module Provider
    module ApplicationControllerMethods

      def self.included(controller_class)
        controller_class.cattr_accessor :oauth_options, :oauth_options_proc
    
        def controller_class.oauth_allowed(options = {}, &block)
          raise 'options cannot contain both :only and :except' if options[:only] && options[:except]
      
          [:only, :except].each do |k|
            if values = options[k]
              options[k] = Array(values).map(&:to_s).to_set
            end
          end
          self.oauth_options = options
          self.oauth_options_proc = block
        end
    
      end
      
      protected
      
      def user_id_for_oauth_access_token
        return nil unless oauth_allowed?
        header_field = request.headers["Authorization"]
        
        if header_field =~ /Token token="(.*)"/          
          token = OauthToken.find_by_access_token($1)
          token.user_id if token
        end
      end
  
      def looks_like_oauth_request?
        header_field = request.headers["Authorization"]
        header_field =~ /Token token="(.*)"/
      end
    
      def oauth_allowed?
        if (oauth_options_proc && !oauth_options_proc.call(self))
          false
        else
          return false if oauth_options.nil?
          oauth_options.empty? ||
            (oauth_options[:only] && oauth_options[:only].include?(action_name)) ||
            (oauth_options[:except] && !oauth_options[:except].include?(action_name))
        end
      end
  
    end
  end
end