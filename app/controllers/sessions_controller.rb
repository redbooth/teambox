# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController

  force_ssl :only => :new
  no_login_required :except => :destroy
  
  skip_before_filter :confirmed_user?
  skip_before_filter :load_project
  skip_before_filter :verify_authenticity_token, :only => :create
  before_filter :set_page_title
  before_filter :community_version_check, :except => :create

  def new
    # Cleanup OAuth login parameters if present
    session.delete :profile
    session.delete :app_link
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
      redirect_back_or_default root_url
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

  # This puts a parameter on your session to force mobile or web version
  def change_format
    if %w(m html).include? params[:f]
      session[:format] = params[:f]
    else
      flash[:error] = "Invalid format"
    end
    
    begin
      redirect_to :back
    rescue ActionController::RedirectBackError
      redirect_to root_path
    end
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = t('sessions.new.login_failed', :login => params[:login])
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
  
  def community_version_check
    return if logged_in?
    if Teambox.config.community
      if User.count == 0
        render 'configure_your_deployment.haml'
      elsif @organization = Organization.first
        render 'sites/show', :layout => 'sites'
      else
        flash[:error] = "The configuration didn't finish. Please log in as #{User.first} and complete it by creating an organization."
        render :new
      end
    end
  end
end
