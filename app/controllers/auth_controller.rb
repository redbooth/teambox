# TODO: Make it run on Heroku

class AuthController < ApplicationController
  skip_before_filter :login_required

  def callback
    provider = params[:provider]
    begin
      auth_hash = params[:auth]
      AppLink.find_by_provider_and_app_user_id_and_user_id(provider, auth_hash[:uid], nil).try(:destroy)
      load_profile(auth_hash, provider)

      if logged_in?
        if current_user.app_links.find_by_provider(@provider)
          flash[:notice] = t(:'oauth.already_linked_to_your_account')
        elsif AppLink.find_by_provider_and_app_user_id(provider, auth_hash[:uid])
          flash[:error] = t(:'oauth.already_taken_by_other_account')
        else
          current_user.link_to_app(provider, auth_hash[:uid])
          flash[:success] = t(:'oauth.account_linked')
        end
        return redirect_to(account_linked_accounts_path)
      else
        if oauth_login(provider, auth_hash[:uid])
          flash[:success] = t(:'oauth.logged_in')
          return redirect_to projects_path
        elsif User.find_by_email(auth_hash[:email])
          # TODO: locate existing user by email and ask to log in to link him
          flash[:notice] = t(:'oauth.user_already_exists_by_email', :email => auth_hash[:email])
          return redirect_to login_path
        elsif User.find_by_login(auth_hash[:login])
          flash[:notice] = t(:'oauth.user_already_exists_by_login', :login => auth_hash[:login])
          return redirect_to login_path
        else
          if signups_enabled?
            session[:profile] = @profile
            app_link = AppLink.create!(:provider => provider, 
                                       :app_user_id => auth_hash[:uid],
                                       :custom_attributes => auth_hash)
            session[:app_link] = app_link.id
            return redirect_to signup_path
          else
            flash[:error] = t(:'users.new.no_public_signup')
            return redirect_to login_path
          end
        end
      end
    rescue
      render :text => %(<p>Authentification Error: #{params[:error]}:</p><p><a href="/auth/#{@provider}">Retry</a></p>)
    end
  end

  def failure
    flash[:error] = "Authentification Error: #{params[:message]}"
    redirect_to :back rescue redirect_to login_path
  end

  private
    # Authentificate with login
    def oauth_login(provider, auth_hash_uid)
      if app_link = AppLink.find(:first, :conditions => {:provider => provider, :app_user_id => auth_hash_uid})
        !!self.current_user = app_link.user if app_link.user
      end
    end

    # Loads user's OAuth profile in @profile
    def load_profile(user, provider)
      @profile = {}
      
      @profile[:login]        = user[:user_info][:nickname]      if user[:user_info][:nickname]
      @profile[:phone]        = user[:user_info][:phone]         if user[:user_info][:phone]
      
      if user[:user_info][:first_name] and user[:user_info][:last_name]
        @profile[:first_name] = user[:user_info][:first_name]
        @profile[:last_name]  = user[:user_info][:last_name]
      else
        @profile[:first_name] = user[:user_info][:name].try(:split).try(:first)
        @profile[:last_name]  = user[:user_info][:name].try(:split).try(:second)
      end

      # Extra
      @profile[:email]        = user[:extra][:user_hash][:email] if user[:extra][:user_hash][:email]

      if @profile[:login]
        @profile[:login] = User.find_available_login(@profile[:login])
      end
    end
end