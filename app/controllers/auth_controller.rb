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
          current_user.link_to_app(provider, auth_hash[:uid], auth_hash[:credentials])
          flash[:success] = t(:'oauth.account_linked')
        end
        return redirect_to(account_linked_accounts_path)
      else
        if oauth_login(provider, auth_hash[:uid])
          flash[:success] = t(:'oauth.logged_in')
          return redirect_to projects_path
        else
          if signups_enabled?
            session[:profile] = @profile
            app_link = AppLink.create!(:provider => provider, 
                                       :app_user_id => auth_hash[:uid],
                                       :custom_attributes => auth_hash,
                                       :access_token => auth_hash[:credentials] ? auth_hash[:credentials][:token] : nil,
                                       :access_secret => auth_hash[:credentials] ? auth_hash[:credentials][:secret] : nil
                                        )
            session[:app_link] = app_link.id
            if conflict?
              return redirect_to login_path
            else
              return redirect_to signup_path
            end
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
    redirect_back_or_to login_path
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
      
      @profile[:provider]     = provider
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
    end

    def conflict?
      email = User.find_by_email(@profile[:email])
      login = User.find_by_login(@profile[:login])

      if email or login
        session[:conflict] = {:email => (@profile[:email] if email), :login => (@profile[:login] if login)}
        true
      else
        false
      end
    end
end