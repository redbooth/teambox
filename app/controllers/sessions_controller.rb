# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  skip_before_filter :login_required, :except => [ :destroy ]
  skip_before_filter :load_project

  # render new.rhtml
  def new
    render :layout => 'login'
  end

  def create
    logout_keeping_session!
    
    if user_from_email = User.find_by_email(params[:login])
      username = user_from_email.login
    else
      username = params[:login]
    end
    
    user = User.authenticate(username, params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      handle_remember_cookie! true
      redirect_back_or_default('/')
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = true
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
