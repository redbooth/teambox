require 'lib/google_docs'

class GoogleDocsController < ApplicationController
  before_filter :create_consumer
  before_filter :get_google_doc, :only => [:show, :write_access]
  before_filter :get_app_link, :get_doc_owner, :get_owner_link, :set_docs, :only => [:show, :write_access]
  before_filter :create_docs_instance, :except => [:show]

  respond_to :js, :only => :write_lock

  rescue_from 'GoogleDocs::RetrievalError' do |exception|
    Rails.logger.warn "#{exception.class.name} #{exception.message}"
    render :authorization_required, :layout => !request.xhr?
  end

  def index
    if params[:project_id]
      # If we ask for /projects/xx/google_docs,
      # then show all the GDocs for that project
      @google_docs = @current_project.google_docs.order("created_at DESC")
      render :index_project
    else
      # If no project is giving, list my personal GDocs
      # for the popup window
      @list = @docs.list(:title => params[:q])
      render :index, :layout => !request.xhr?
    end
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

    @role = @google_doc.write_lock == false ? :writer : :reader

    @docs.add_permission(@google_doc.acl_url, @app_link.app_user_id, :user, @role)
    access_key = @docs.set_read_with_key(@google_doc.acl_url, @role)
    url_with_access_key = @google_doc.url + (@google_doc.url.include?('?') ? "&authkey=#{access_key}" : "?authkey=#{access_key}")

    redirect_to url_with_access_key
  end

  def write_access

    @access = params[:access].to_sym
    @role = @access == :lock ? :reader : :writer

    @acl = @docs.acl_list(@google_doc.acl_url, {}, {:other_users_only => true})

    @acl.each do |acl_item|
      @docs.change_permission(@google_doc.acl_url, acl_item[:user_email], :user, @role, acl_item[:etag])
    end

    if @acl.first.nil?
      @docs.set_read_with_key(@google_doc.acl_url, @role)
    else
      @docs.update_read_with_key(@google_doc.acl_url, @role, @acl.first[:etag])
    end

    @google_doc.update_attribute :write_lock, @access == :lock

    respond_to do |f|
      f.any(:html, :m)
      f.js {
        render :layout => false
      }
    end

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

    @docs = GoogleDocs.new(@app_link.credentials['token'], @app_link.credentials['secret'], @consumer)
  end

  def get_auth_config
    if Teambox.config.providers?
      Teambox.config.providers.detect { |p| p.provider == 'google' }
    else
      []
    end
  end

  def get_google_doc
    @google_doc = @current_project.google_docs.find(params[:id])
  end

  def get_app_link
    @app_link = current_user.app_links.find_by_provider('google')
    unless @app_link
      render :authorization_required, :layout => !request.xhr?
      return false
    end
  end

  def get_doc_owner
    @doc_owner = @google_doc.user
    unless @doc_owner
      render :text => 'This user does not exist any more', :layout => !request.xhr?
      return false
    end
  end

  def get_owner_link
    # find the app link for the document owner to get their access token and secret
    @owner_link = @doc_owner.app_links.find_by_provider('google')
    unless @owner_link
      render :text => 'The document owner has unlinked google', :layout => !request.xhr?
      return false
    end
  end

  def set_docs
    @docs = GoogleDocs.new(@owner_link.credentials['token'], @owner_link.credentials['secret'], @consumer)
  end

end
