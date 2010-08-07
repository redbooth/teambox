class UsersController < ApplicationController
  no_login_required :only => [ :new, :create, :confirm_email, :forgot_password, :reset_password, :login_from_reset_password ]
  
  before_filter :find_user, :only => [ :show, :confirm_email, :login_from_reset_password ]
  before_filter :load_invitation, :only => [ :new, :create ]
  skip_before_filter :confirmed_user?, :only => [ :new, :create, :confirm_email, :forgot_password, :reset_password, :login_from_reset_password, :unconfirmed_email ]
  skip_before_filter :load_project
  before_filter :set_page_title

  def index
    # show current user
    respond_to do |f|
      f.html { redirect_to '/' }
      f.m { redirect_to '/' }
      f.xml   { render :xml     => @current_user.users_with_shared_projects.to_xml(:root => 'users') }
      f.json  { render :as_json => @current_user.users_with_shared_projects.to_xml(:root => 'users') }
      f.yaml  { render :as_yaml => @current_user.users_with_shared_projects.to_xml(:root => 'users')}
    end
  end
  
  def new
    if logged_in?
      flash[:success] = t('users.new.you_are_logged_in')
      redirect_to projects_path
    else
      load_app_link
      load_profile

      @user ||= User.new
      @user.email = @invitation.email if @invitation

      render :layout => 'sessions'
    end
  end

  def show
    @card = @user.card
    projects_shared = @user.projects_shared_with(@current_user)
    @shares_invited_projects = projects_shared.empty? && @user.shares_invited_projects_with?(@current_user)
    @activities = @user.activities_visible_to_user(@current_user)
    
    respond_to do |format|
      if @user != @current_user and (!@shares_invited_projects and projects_shared.empty?)
        format.html {
          flash[:error] = t('users.activation.invalid_user')
          redirect_to root_path
        }
      else
        format.html
        format.m
        format.xml  { render :xml => @user.to_xml }
        format.json { render :as_json => @user.to_xml }
        format.yaml { render :as_yaml => @user.to_xml }
      end
    end
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])

    load_app_link

    @user.confirmed_user = ((@invitation && @invitation.email == @user.email) or
                            Rails.env.development? or
                            !!@app_link)

    unless @invitation || signups_enabled?
      flash[:error] = t('users.new.no_public_signup')
      return redirect_to root_path
    end

    if @user && @user.save && @user.errors.empty?
      self.current_user = @user

      if @app_link
        @app_link.user = @user
        @app_link.save!
      end

      if @invitation
        if @invitation.project
          redirect_to(project_path(@invitation.project))
        else
          redirect_to(group_path(@invitation.group))
        end
      else
        redirect_back_or_default root_path
      end

      flash[:success] = t('users.create.thanks')
    else
      load_profile
      render :action => :new, :layout => 'sessions'
    end
  end

  def edit
    if params.has_key?(:sub_action)
      @sub_action = params[:sub_action]
    else
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
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
        flash[:error] = t('users.activation.invalid')
      end
    else
      flash[:error] = t('users.activation.invalid_user')
    end
    redirect_to root_path
  end

  def welcome
    @pending_projects = current_user.invitations

    if current_user.welcome
      respond_to do |format|
        format.html { redirect_to projects_path }
      end
    end
  end

  def text_styles
    render :layout => false
  end

  def calendars
  end

  def feeds
  end

  def close_welcome
    @current_user.update_attribute(:welcome,true)
    respond_to do |format|
      format.html { redirect_to projects_path }
    end
  end
  
  def destroy
    if current_user.projects.count == 0 && current_user.projects.archived.count == 0
      user = current_user
      logout_killing_session!
      flash[:success] = t('users.form.account_deletion.account_deleted')
      user.destroy
      redirect_to login_path
    else
      flash[:error] = t('users.form.account_deletion.couldnt_delete_account')
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

    def load_app_link
      if session[:app_link]
        @app_link = AppLink.find(session[:app_link]) || raise("Invalid AppLink")
        raise("AppLink already in use") if @app_link.user_id
      end
    end

    def load_profile
      @user ||= User.new
      if @profile = session[:profile]
        @user.first_name    = @user.first_name.presence || @profile[:first_name]
        @user.last_name     = @user.last_name.presence  || @profile[:last_name]
        @user.login       ||= @profile[:login]
        @user.email       ||= @profile[:email]
      end
    end
end
