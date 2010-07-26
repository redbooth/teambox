module Oauth2
  module Provider
    class OauthClientsController < ApplicationController
      skip_filter :load_project
      
      def index
        @oauth_clients = @current_user.oauth_clients
      end

      def show
        @oauth_client = @current_user.oauth_clients.find(params[:id])
      end

      def new
        @oauth_client = @current_user.oauth_clients.new
      end

      def edit
        @oauth_client = @current_user.oauth_clients.find(params[:id])
      end

      def create
        @oauth_client = @current_user.oauth_clients.new(params[:oauth_client])
        
        if @oauth_client.save
          flash[:notice] = 'OauthClient was successfully created.'
          redirect_to oauth_client_path(@oauth_client)
        else
          render :action => "new" 
        end
      end

      def update
        @oauth_client = @current_user.oauth_clients.find(params[:id])

        if @oauth_client.update_attributes(params[:oauth_client])
          flash[:notice] = 'OauthClient was successfully updated.'
          redirect_to oauth_client_path(@oauth_client)
        else
          render :action => "edit"
        end
      end

      def destroy
        @oauth_client = OauthClient.find(params[:id])
        @oauth_client.destroy

        redirect_to(oauth_clients_url)
      end
    end
  end
end
