class ApiV2::APIController < ActionController::Base
  before_filter :set_client

  protected
  def api_respond(object, options={})
    respond_to do |f|
      f.json { render :json => api_wrap(object, options).to_json }
      f.js   { render :json => api_wrap(object, options).to_json, :callback => params[:callback] }
    end
  end

  def set_client
    request.format = :json unless request.format == :js
  end
end

