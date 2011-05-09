require 'oauth/signature'
module Oauth
  module Controllers
   
    module ApplicationControllerMethods
      
      def self.included(controller)
        controller.class_eval do  
          extend ClassMethods
        end
      end
      
      module ClassMethods
        def oauthenticate(options={})
          filter_options = {}
          filter_options[:only]   = options.delete(:only) if options[:only]
          filter_options[:except] = options.delete(:except) if options[:except]
          before_filter Filter.new(options), filter_options
        end
      end
      
      class Filter
        def initialize(options={})
          @options={
              :interactive=>true,
              :strategies => [:token,:two_legged]
            }.merge(options)
          @strategies = Array(@options[:strategies])
          @strategies << :interactive if @options[:interactive]
        end
        
        def filter(controller)
          Authenticator.new(controller,@strategies).allow?
        end
      end
      
      class Authenticator
        attr_accessor :controller, :strategies, :strategy
        def initialize(controller,strategies)
          @controller = controller
          @strategies = strategies
        end
        
        def params
          controller.send :params
        end
        
        def request
          controller.send :request
        end
        
        def env
          request.env
        end
        
        def using_rack_filter?
          request.env["oauth_plugin"]
        end
        
        def allow?
          if @strategies.any? do |strategy| 
              @strategy  = strategy.to_sym
              send @strategy
            end
            true
          else
            if @strategies.include?(:interactive) 
              controller.send :access_denied
            else
              controller.send :invalid_oauth_response
            end
          end
        end

        def oauth20_token
          return false unless defined?(Oauth2Token)
          token, options = token_and_options
          token ||= params[:oauth_token] || params[:access_token]
          if !token.blank?
            @oauth2_token = Oauth2Token.find_by_token(token)
            if @oauth2_token && @oauth2_token.authorized?
              controller.send :current_token=, @oauth2_token
            else
              @oauth2_token = nil
            end
          end
          @oauth2_token!=nil
        end
        
        def token
          oauth20_token
        end
        
        def two_legged
          if using_rack_filter?
            if env["oauth.client_application"]
              @client_application = env["oauth.client_application"]
              controller.send :current_client_application=, @client_application
            end
          else
            begin
              if ClientApplication.verify_request(request) do |request_proxy|
                  @client_application = ClientApplication.find_by_key(request_proxy.consumer_key)

                  # Store this temporarily in client_application object for use in request token generation 
                  @client_application.token_callback_url=request_proxy.oauth_callback if request_proxy.oauth_callback

                  # return the token secret and the consumer secret
                  [nil, @client_application.secret]
                end
                controller.send :current_client_application=, @client_application
                true
              else
                false
              end
            rescue
              false
            end
          end
        end
        
        def interactive
          @controller.send :logged_in?
        end
        
        # Blatantly stolen from http://github.com/technoweenie/http_token_authentication
        # Parses the token and options out of the OAuth authorization header.  If
        # the header looks like this:
        #   Authorization: OAuth abc
        # Then the returned token is "abc", and the options is {:nonce => "def"}
        #
        # request - ActionController::Request instance with the current headers.
        #
        # Returns an Array of [String, Hash] if a token is present.
        # Returns nil if no token is found.
        def token_and_options
          if header = (request.respond_to?(:authorization) ? request.authorization : ActionController::HttpAuthentication::Basic.authorization(request)).to_s[/^OAuth (.*)/]
            [$1.strip, {}]
          end
        end

      end
              
      protected
      
      def current_token
        @current_token
      end
      
      def current_client_application
        @current_client_application
      end
      
      def oauth?
        current_token!=nil
      end
      
      def invalid_oauth_response(code=401,message="Invalid OAuth Request")
        render :text => message, :status => code
        false
      end
      
      # override this in your controller
      def access_denied
        head 401
      end

      private
      
      def current_token=(token)
        @current_token=token
        if @current_token
          @current_user=@current_token.user
          @current_client_application=@current_token.client_application
        else
          @current_user = nil
          @current_client_application = nil
        end
        @current_token
      end
      
      def current_client_application=(app)
        if app
          @current_client_application = app
          @current_user = app.user
        else
          @current_client_application = nil
          @current_user = nil
        end
      end
    end
  end
end