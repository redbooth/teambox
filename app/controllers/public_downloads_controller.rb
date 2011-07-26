class PublicDownloadsController < ApplicationController

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

  before_filter :get_upload_by_token
  # TODO before_filter :set_headers no store, no cache

  def download_send

    # OPTIMIZE copied from uploads controller, may be encapsulated in a module for DRY
    
    if !!Teambox.config.amazon_s3
      unless @upload.asset.exists?(params[:style])
        head(:bad_request)
        raise "Unable to download file"
      end
      redirect_to @upload.s3_url(params[:style])
    else
      path = @upload.asset.path(params[:style])
      unless File.exist?(path)
        head(:bad_request)
        raise "Unable to download file"
      end

      mime_type = File.mime_type?(@upload.asset_file_name)

      mime_type = 'application/octet-stream' if mime_type == 'unknown/unknown'

      send_file_options = {:type => mime_type}.merge(@extra_sendfile_options || {})

      response.headers['Cache-Control'] = 'private, max-age=31557600'

      send_file(path, send_file_options)
    end

  end

  private

  def get_upload_by_token
    unless @upload = Upload.find_by_token(params[:token])
      flash.now[:error] = 'File not found'
      render :template => "public_downloads/not_found", :layout => "public_downloads", :status => :not_found and return
    end
  end

end