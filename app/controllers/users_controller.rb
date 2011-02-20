class UsersController < ApplicationController
  no_login_required :only => [ :new, :create, :confirm_email, :forgot_password, :reset_password, :login_from_reset_password ]
  
  before_filter :find_user, :only => [ :show, :confirm_email, :login_from_reset_password ]
  before_filter :load_invitation, :only => [ :new, :create ]
  skip_before_filter :confirmed_user?, :only => [ :new, :create, :confirm_email, :forgot_password, :reset_password, :login_from_reset_password, :unconfirmed_email ]
  skip_before_filter :load_project
  before_filter :set_page_title
  before_filter :can_users_signup?, :only => [:new, :create]

  def index
    # show current user
    respond_to do |f|
      f.any(:html, :m)  { redirect_to root_path }
      f.xml   { render :xml     => @current_user.users_with_shared_projects.to_xml(:root => 'users') }
      f.json  { render :as_json => @current_user.users_with_shared_projects.to_xml(:root => 'users') }
      f.yaml  { render :as_yaml => @current_user.users_with_shared_projects.to_xml(:root => 'users')}
    end
  end
  
  def new
    # Trying to accept a new account invitation, but you're already logged in
    if @invitation and logged_in?
      @invitation.invited_user = current_user
      @invitation.save
      flash[:success] = t('users.new.you_are_logged_in')
      return redirect_to projects_url(:invitation => @invitation.token)
    # Trying to create a user, but you're already logged in
    elsif logged_in?
      flash[:success] = t('users.new.you_are_logged_in')
      return redirect_to projects_path
    else
      # Create an account from OAuth
      if session[:profile] and session[:app_link]
        signup_from_oauth(session[:profile], session[:app_link])
      # Regular invitation
      else
        @user = User.new
        @user.email = @invitation.email if @invitation
      end
    end
    
    respond_to do |f|
      f.any(:html, :m) { render :layout => 'sessions' }
    end
  end

  def show
    @card = @user.card
    @projects_shared = @user.projects_shared_with(@current_user)
    @shares_invited_projects = @projects_shared.empty? && @user.shares_invited_projects_with?(@current_user)
    @activities = Activity.for_projects(@user.projects_shared_with(@current_user)).from_user(@user)
    @threads = @activities.threads
    @last_activity = @activities.all.last

    respond_to do |format|
      if @user != @current_user and (!@shares_invited_projects and @projects_shared.empty?)
        format.any(:html, :m) {
          flash[:error] = t('users.activation.invalid_user')
          redirect_to root_path
        }
      else
        format.any(:html, :m)
        format.xml  { render :xml => @user.to_xml }
        format.json { render :as_json => @user.to_xml }
        format.yaml { render :as_yaml => @user.to_xml }
      end
    end
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])

    @user.confirmed_user = ((@invitation && @invitation.email == @user.email) or 
                            (session[:profile] && session[:profile][:email] == @user.email) or
                            Rails.env.development? or !Teambox.config.email_confirmation_require)

    if @user && @user.save
      self.current_user = @user

      if applink = AppLink.find_by_id(session[:applink])
        applink.user = @user
        applink.save
      end

      if @invitation
        # Can be an invitation to a project or just to Teambox
        if @invitation.project
          redirect_to project_path(@invitation.project)
        else
          redirect_to projects_path
        end
      else
        redirect_back_or_default root_path
      end

      flash[:success] = t('users.create.thanks')
    else
      respond_to do |f|
        f.any(:html, :m) { render :action => :new, :layout => 'sessions' }
      end
    end
  end

  def edit
    if params.has_key?(:sub_action)
      @sub_action = params[:sub_action]
    else
      render :file => "#{Rails.root}/public/404.html", :status => 404
    end
  end

  def update
    @sub_action = params[:sub_action]
    success = current_user.update_attributes(params[:user])
    
    respond_to do |wants|
      wants.html {
        if success
          back = polymorphic_url [:account, @sub_action]
          flash[:success] = t('users.update.updated', :locale => current_user.locale)
          redirect_to back
        else
          flash.now[:error] = t('users.update.error')
          render 'edit'
        end
      }
    end
  end

  def unconfirmed_email
    redirect_to root_path and return if current_user.is_active?

    if params[:resend]
      current_user.send_activation_email
      flash[:success] = t('users.activation.resent')
    end

    @email = current_user.email
    render :layout => 'sessions'
  end

  def confirm_email
    logout_keeping_session!
    if @user
      if @user.is_login_token_valid? params[:token]
        if @user.is_active?
          flash[:success] = t('users.activation.already_done')
        else
          flash[:success] = t('users.activation.activated')
          @user.activate!
          @user.expire_login_code!
          self.current_user = @user
        end
      else
        flash[:error] = t('users.activation.invalid_html')
      end
    else
      flash[:error] = t('users.activation.invalid_user')
    end
    redirect_to root_path
  end

  def text_styles
    render :layout => false
  end

  def calendars
  end

  def feeds
  end

  def destroy
    if current_user.projects.count == 0 && current_user.projects.archived.count == 0
      user = current_user
      logout_killing_session!
      flash[:success] = t('users.form.delete.account_deleted')
      user.destroy
      redirect_to login_path
    else
      flash[:error] = t('users.form.delete.couldnt_delete_account')
      redirect_to account_delete_path
    end
  end

  def unlink_app
    if app_link = current_user.app_links.find_by_provider(params[:provider])
      flash[:success] = t(:'oauth.app_unlinked')
      app_link.destroy
    else
      flash[:error] = t(:'oauth.not_linked')
    end

    redirect_to account_linked_accounts_path
  end

  def disable_splash
    current_user.update_attribute :splash_screen, false
    head :ok
  end

  def change_activities_mode
    @current_user.settings = { :collapse_activities => params[:collapsed] }
    @current_user.save!
    render :text => "activities are now #{params[:collapsed] ? 'collapsed' : 'expanded'}"
  end

  private
    def find_user
      unless @user = ( User.find_by_login(params[:id]) || User.find_by_id(params[:id]) )
        flash[:error] = t('not_found.user')
        redirect_to root_path
      end
    end

    def load_invitation
      if params[:invitation]
        @invitation = Invitation.find_by_token(params[:invitation])
        @invitation_token = params[:invitation] if @invitation
      end
    end

    def signup_from_oauth(profile, app_link)
      @user ||= User.new
      @user.first_name    = @user.first_name.presence || profile[:first_name]
      @user.last_name     = @user.last_name.presence  || profile[:last_name]
      if profile[:login]
        @user.login     ||= User.find_available_login(profile[:login])
      end

      @user.email       ||= profile[:email] unless User.find_by_email(profile[:email])

      @provider = profile[:provider]
    end

    def can_users_signup?
      unless @invitation || signups_enabled?
        flash[:error] = t('users.new.no_public_signup')
        return redirect_to Teambox.config.community ? login_path : root_path
      end
    end
end
