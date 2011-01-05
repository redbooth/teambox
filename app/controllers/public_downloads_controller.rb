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

  def download
    @upload = Upload.first
    render :layout => 'public_downloads'
  end

end