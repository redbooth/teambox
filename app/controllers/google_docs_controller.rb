require 'lib/google_docs'

class GoogleDocsController < ApplicationController
  before_filter :create_consumer 
  before_filter :create_docs_instance
  
  rescue_from 'GoogleDocs::RetrievalError' do |exception|
    Rails.logger.warn "#{exception.class.name} #{exception.message}"
    render :authorization_required, :layout => !request.xhr?
  end 
  
  def index
    @list = @docs.list(:title => params[:q])
    render :index, :layout => !request.xhr?
  end
  
  def search
    index and return unless request.xhr?
      
    @list = @docs.list(:title => params[:q])
    render :partial => 'list', :layout => false
  end
  
  def create
    doc = @docs.create(params[:google_doc])
    
    # We don't want to create an actual doc here just return the details so we can insert it using js
    render :json => doc, :status => 201, :callback => params[:callback]
  end
  
  def show
    @google_doc = @current_project.google_docs.find(params[:id])
    res = @docs.add_permission(@google_doc.acl_url, @app_link.app_user_id, :user, :reader)
    
    redirect_to @google_doc.url
  end

  protected
    def create_consumer
      auth_config = get_auth_config
      unless auth_config
        render :text => 'You have not added a google docs provider'
        return false 
      end
      
      @consumer = OAuth::Consumer.new(auth_config.key, auth_config.secret, GoogleDocs::RESOURCES)
    end
    
    def create_docs_instance
      @app_link = current_user.app_links.find_by_provider('google')
      unless @app_link
        render :authorization_required, :layout => !request.xhr?
        return false
      end
      
      @docs = GoogleDocs.new(@app_link.access_token, @app_link.access_secret, @consumer)
    end
    
    def get_auth_config
      Teambox.config.providers.detect { |p| p.provider == 'google' }
    end
end
