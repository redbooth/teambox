module Oauth2
  module Provider
    class OauthTokenController < ApplicationController
      skip_before_filter :verify_authenticity_token
      no_login_required
      
      def get_token
        unless ['authorization-code', 'refresh-token', 'password'].include?(params[:grant_type])
          render_error('unsupported-grant-type')
          return
        end
    
        client = OauthClient.find_by_client_id_and_client_secret(params[:client_id], params[:client_secret])

        case params[:grant_type]
          when 'password' # see 'Resource Owner Password Credentials' grant_type, http://tools.ietf.org/html/draft-ietf-oauth-v2-10#section-4.1.2
            user = User.authenticate(params[:username], params[:password])
            authorization = client.create_authorization_for_user_id(user.id) if user
          when 'authorization-code'
            authorization = OauthAuthorization.find_by_code(params[:code])
        end
        
        original_token = OauthToken.find_by_refresh_token(params[:refresh_token])
        original_token.delete unless original_token.nil?
        
        if client.nil?
          render_error('invalid-client-credentials')
          return
        end
    
        if client.redirect_uri != params[:redirect_uri] and params[:grant_type] != 'password'
          render_error('invalid-grant')
          return
        end
    
        case params[:grant_type]
        when 'authorization-code'
          if authorization.nil? || authorization.expired? || authorization.oauth_client != client
            render_error('invalid-grant')
            return
          end
          token = authorization.generate_access_token
        when 'password'
          if authorization.nil? || authorization.expired? 
            render_error('invalid-grant')
            return
          end
          token = authorization.generate_access_token
        when 'refresh-token'
          if original_token.nil? || original_token.oauth_client != client
            render_error('invalid-grant' + client.id)
            return
          end
          token = original_token.refresh
        else
          render_error('invalid-grant')
          return
        end
        authorization.delete unless authorization.nil?
        
        render :content_type => 'application/json', :text => token.access_token_attributes.to_json
      end
  
      private
      def render_error(error_code)
         render :status => :bad_request, :json => {:error => error_code}.to_json
      end
  
    end
  end
end