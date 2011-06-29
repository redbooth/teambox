# TODO: Make it run on Heroku

class AuthController < ApplicationController
  skip_before_filter :login_required

  def callback
    provider = params[:provider]
    redirect_on_failure unless auth_hash = Hashie::Mash.new(request.env['omniauth.auth'])
    app_link = AppLink.find_or_create_or_update_from_authentification(provider, auth_hash, current_user)

    if logged_in?
      if current_user.id == app_link.user_id
        flash[:success] = t(:'oauth.account_linked')
      else
        flash[:error] = t(:'oauth.already_taken_by_other_account')
      end
      return redirect_to account_linked_accounts_url
    elsif app_link.user
      self.current_user = app_link.user
      flash[:success] = t(:'oauth.logged_in')
      return redirect_to projects_url
    elsif !signups_enabled?
      flash[:error] = t(:'users.new.no_public_signup')
      return redirect_to login_url
    else
      session[:app_link_id] = app_link.id
      return redirect_to signup_url
    end
  end

  def failure
    redirect_on_failure params[:message].humanize
  end

  protected
  def redirect_on_failure(message=nil)
    message ||= "communication error"
    flash[:error] = t('oauth.authentication_failure', :message => message)
    if logged_in?
      return redirect_to account_linked_accounts_url
    else
      return redirect_to login_url
    end
  end
end
