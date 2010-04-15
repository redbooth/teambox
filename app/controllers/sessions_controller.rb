# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  no_login_required :except => :destroy
  
  skip_before_filter :confirmed_user?
  skip_before_filter :load_project
  before_filter :set_page_title

  def new  
    @signups_enabled = signups_enabled?
    respond_to do |format|
      format.html { redirect_to root_path if logged_in? }
      format.m
    end
  end

  def create
    @signups_enabled = signups_enabled?
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
      redirect_back_or_default root_path
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = true
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    redirect_back_or_default root_path
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = t('sessions.new.login_failed', :login => h(params[:login]))
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
