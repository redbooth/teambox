module Oauth2
  module Provider
    class OauthTokenController < ApplicationController
      skip_before_filter :verify_authenticity_token
      no_login_required
      
      def get_token
        
        authorization = OauthAuthorization.find_by_code(params[:code])
        authorization.delete unless authorization.nil?
        
        original_token = OauthToken.find_by_refresh_token(params[:refresh_token])
        original_token.delete unless original_token.nil?
    
        unless ['authorization-code', 'refresh-token'].include?(params[:grant_type])
          render_error('unsupported-grant-type')
          return
        end
    
        client = OauthClient.find_by_client_id_and_client_secret(params[:client_id], params[:client_secret])
    
        if client.nil?
          render_error('invalid-client-credentials')
          return
        end
    
        if client.redirect_uri != params[:redirect_uri]
          render_error('invalid-grant')
          return
        end
    
        if params[:grant_type] == 'authorization-code'
          if authorization.nil? || authorization.expired? || authorization.oauth_client != client
            render_error('invalid-grant')
            return
          end
          token = authorization.generate_access_token
        else # refresh-token
          if original_token.nil? || original_token.oauth_client != client
            render_error('invalid-grant')
            return
          end
          token = original_token.refresh
        end

        render :content_type => 'application/json', :text => token.access_token_attributes.to_json
      end
  
      private
      def render_error(error_code)
         render :status => :bad_request, :json => {:error => error_code}.to_json
      end
  
    end
  end
end