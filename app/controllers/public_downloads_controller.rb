class PublicDownloadsController < ApplicationController

  include Downloads::Downloading

  skip_filter :set_locale,
              :rss_token,
              :confirmed_user?, 
              :load_project, 
              :load_organizations,
              :set_client,
              :login_required, 
              :touch_user,
              :belongs_to_project?,
              :load_community_organization,
              :add_chrome_frame_header

  # TODO before_filter :set_headers no store, no cache
  before_filter :get_upload_by_token, :only => [:download, :download_send]
  before_filter :get_folder_by_token, :only => [:folder]

  def download
  end

  def download_send
    download_send_file(@upload)
  end

  def folder
    @folders = @folder.folders
    @uploads = @folder.uploads
  end

  private

  def get_upload_by_token
    unless @upload = Upload.find_by_token_and_deleted(params[:token], false)
      @upload = Upload.new
      render :template => "public_downloads/not_found", :layout => "public_downloads", :status => :not_found and return
    end
  end

  def get_folder_by_token
    unless @folder = Folder.find_by_token_and_deleted(params[:token], false)
      @folder = Folder.new
      render :template => "public_downloads/not_found", :layout => "public_downloads", :status => :not_found and return
    end
  end

end