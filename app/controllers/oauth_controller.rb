# TODO: Make it run on Heroku

class OauthController < ApplicationController
  skip_before_filter :login_required

  # Starts the redirect authorization for OAuth
  def start
    @provider = params[:provider]
    url = client.web_server.authorize_url(
      :redirect_uri => oauth_callback_url,
      :scope => 'email,offline_access')

    redirect_to url
  end

  # Returns the user from the OAuth provider
  def callback
    @provider = params[:provider]
    begin
      @access_token = client.web_server.get_access_token(
        params[:code], :redirect_uri => oauth_callback_url)

      load_profile

      if logged_in?
        if current_user.app_links.find_by_provider(@provider)
          flash[:notice] = t(:'oauth.already_linked_to_your_account')
        elsif AppLink.find_by_provider_and_app_user_id(@provider, @profile[:id])
          flash[:error] = t(:'oauth.already_taken_by_other_account')
        else
          current_user.link_to_app(@provider, @profile)
          flash[:success] = t(:'oauth.account_linked')
        end
        return redirect_to(account_linked_accounts_path)
      else
        if oauth_login
          flash[:success] = t(:'oauth.logged_in')
          return redirect_to projects_path
        elsif User.find_by_email(@profile[:email])
          # TODO: locate existing user by email and ask to log in to link him
          flash[:notice] = "The user #{@profile[:email]} has already a Teambox account.<br/>Log in and link it from your Settings panel."
          redirect_to login_path
        else
          if signups_enabled?
            profile_for_session = @profile
            profile_for_session.delete(:original)
            session[:profile] = profile_for_session
            app_link = AppLink.create!(:provider => @provider, 
                                       :app_user_id => @profile[:id], 
                                       :custom_attributes => @profile[:original])
            session[:app_link] = app_link.id
            return redirect_to signup_path
          else
            flash[:error] = t(:'users.new.no_public_signup')
            return redirect_to login_path
          end
        end
      end
    rescue OAuth2::HTTPError
      render :text => %(<p>OAuth Error ?code=#{params[:code]}:</p><p>#{$!}</p><p><a href="/auth/#{@provider}">Retry</a></p>)
    end
  end

  private
    # TODO: This will cause duplicate username and email problems
    # This should, instead, be a redirect to signup that doesn't require email
    # confirmation and that links to the OAuth account. This could be kept on session
    # TODO: Add 'source' field to users to track where they signed up from
    def oauth_signup
      new_user = User.create! do |u|
        u.first_name  = @profile[:first_name]
        u.last_name   = @profile[:last_name]
        u.login       = @profile[:login] || (@profile[:first_name] + "_" + ActiveSupport::SecureRandom.hex(2))
        u.email       = @profile[:email]
        u.password    = u.password_confirmation = ActiveSupport::SecureRandom.hex(20)
      end

      new_user.activate!
      new_user.card = Card.create
      new_user.link_to_app(@provider, @profile)

      self.current_user = new_user
      new_user
    end

    # Logs in with the chosen provider, if the AppLink exists
    def oauth_login
      user = AppLink.find_by_provider_and_app_user_id(@provider, @profile[:id]).try(:user)
      !!self.current_user = user
    end

    # Prepares a OAuth client
    def client
      @config = APP_CONFIG['oauth_providers'][@provider]
      raise "Provider #{@provider} is missing. Please add the key and secret to the configuration file." unless @config
      @client ||= OAuth2::Client.new(
        @config['client_id'],
        @config['secret_key'],
        :site => @config['site'],
        :authorize_path => @config['authorize_path'],
        :access_token_path => @config['access_token_path'])
    end

    # Loads user's OAuth profile in @profile
    def load_profile
      @profile = {}

      user = JSON.parse(@access_token.get(@config['user_path']))

      case @provider
      when "github"
        user = user['user']
        @profile[:id]         = user['id']
        @profile[:email]      = user['email']
        @profile[:login]      = user['login']
        @profile[:first_name] = user['name'].split.first
        @profile[:last_name]  = user['name'].split.second
        @profile[:company]    = user['company']
        @profile[:location]   = user['location']
        @profile[:original]   = user
      when "facebook"
        @profile[:id]         = user['id']
        @profile[:email]      = user['email']
        @profile[:first_name] = user['first_name']
        @profile[:last_name]  = user['last_name']
        @profile[:location]   = user['location']['name'] if user['location']
        @profile[:original]   = user
      else
        raise "Unsupported provider: '#{@provider}'"
      end
    end
end
