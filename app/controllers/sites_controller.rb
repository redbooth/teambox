# This controller handles custom organization pages and login for them
class SitesController < ApplicationController

  no_login_required
  
  skip_before_filter :confirmed_user?
  skip_before_filter :load_project
  skip_before_filter :verify_authenticity_token, :only => :create
  before_filter :set_page_title, :load_organization

  layout 'sites'

  def show
    # Cleanup OAuth login parameters if present
    session.delete :profile
    session.delete :app_link
  end

  def create
    logout_keeping_session!
    
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      handle_remember_cookie! true
      flash[:error] = nil
      redirect_back_or_default root_url
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = true
      render :show
    end
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = t('sessions.new.login_failed', :login => params[:login])
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  def load_organization
    @organization = Organization.find_by_permalink(params[:id])
    unless @organization
      render :text => "That organization doesn't exist. But if it did, it'd surely be using Teambox!"
    end
  end

end
