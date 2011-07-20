# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController

  no_login_required :except => :destroy

  skip_before_filter :confirmed_user?
  skip_before_filter :load_project
  skip_before_filter :verify_authenticity_token, :only => :create
  before_filter :set_page_title
  before_filter :community_version_check, :except => [:create, :backdoor]

  def new
    clear_auth_session! unless @conflict = session[:conflict] and @profile = session[:profile]

    @signups_enabled = signups_enabled?
    respond_to do |format|
      format.html { redirect_to root_path if logged_in? }
      format.m { redirect_to activities_path if logged_in? }
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

      if session[:app_link]
        app_link = AppLink.find_by_id(session[:app_link])
        app_link.user = user
        app_link.save
        clear_auth_session!
      end

      respond_to do |format|
        format.html { redirect_back_or_default root_url }
        format.m { redirect_back_or_default activities_url }
      end
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = true
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    clear_auth_session!
    redirect_back_or_default root_path
  end
  
  # for cucumber testing only
  def backdoor
    logout_killing_session!
    self.current_user = User.find_by_login!(params[:username])
    head :ok
  end

  # This puts a parameter on your session to force mobile or web version
  def change_format
    if %w(m html).include? params[:f]
      session[:format] = params[:f]
    else
      flash[:error] = "Invalid format"
    end
    
    redirect_back_or_to root_path
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = t('sessions.new.login_failed', :login => params[:login])
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  def clear_auth_session!
    session.delete :profile
    session.delete :app_link
    session.delete :conflict
  end

  def community_version_check
    return if logged_in?
    if Teambox.config.community
      if User.count == 0
        respond_to do |f|
          f.html { render 'configure_your_deployment.haml' }
          f.m { render 'configure_your_deployment.haml' }
        end
      elsif @organization = Organization.first
        respond_to do |f|
          f.html { render 'sites/show', :layout => 'sites' }
          f.m { render 'sites/show', :layout => 'sites' }
        end
      else
        flash[:error] = "The configuration didn't finish. Please log in as #{User.first} and complete it by creating an organization."
        respond_to do |f|
          f.html { render :new }
          f.m { render :new }
        end
      end
    end
  end
end
