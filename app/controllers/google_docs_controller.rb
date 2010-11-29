class GoogleDocsController < ApplicationController
  before_filter :create_consumer 
  before_filter :create_docs_instance, :except => [:authorize, :call_back]
  
  rescue_from 'GoogleDocs::RetrievalError' do |exception|
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
  
  def authorize
    request_token = @consumer.get_request_token({:oauth_callback => call_back_google_docs_url}, {:scope => GoogleDocs::RESOURCES[:scope]})
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret
    redirect_to request_token.authorize_url
  end
  
  def call_back
    request_token = OAuth::RequestToken.new(@consumer, session[:request_token], session[:request_secret])
    access_token = request_token.get_access_token(:oauth_verifier => request.params['oauth_verifier'])
    session[:access_token] = access_token.token
    session[:access_secret] = access_token.secret
    flash[:notice] = "You account was successfuly linked to Google. We will do this properly soon"
    redirect_to account_linked_accounts_path
  end
  
  def clear
    session[:access_token] = nil
    session[:access_secret] = nil
  end
  
  protected
    def create_consumer
      auth_config = get_auth_config
      @consumer = OAuth::Consumer.new(auth_config.key, auth_config.secret, GoogleDocs::RESOURCES)
    end
    
    def create_docs_instance
      @docs = GoogleDocs.new(session[:access_token], session[:access_secret], @consumer)
    end
    
    def get_auth_config
      Teambox.config.providers.each do |provider|
        return provider if provider.provider == 'google_docs'
      end
      return false
    end
end
