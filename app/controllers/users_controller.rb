class UsersController < ApplicationController
  no_login_required :only => [ :new, :create, :confirm_email, :forgot_password, :reset_password, :login_from_reset_password ]
  
  before_filter :find_user, :only => [ :show, :confirm_email, :login_from_reset_password ]
  before_filter :load_invitation, :only => [ :new, :create ]
  skip_before_filter :confirmed_user?, :only => [ :new, :create, :confirm_email, :forgot_password, :reset_password, :login_from_reset_password, :unconfirmed_email ]
  skip_before_filter :load_project
  before_filter :set_page_title

  def new
    if logged_in?
      flash[:success] = t('users.new.you_are_logged_in')
      redirect_to projects_path
    else
      @user = User.new
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
    @user.confirmed_user = true if @invitation && @invitation.email == @user.email
    
    unless @invitation || signups_enabled?
      flash[:error] = t('users.new.no_public_signup')
      redirect_to root_path
      return
    end

    if @user && @user.save && @user.errors.empty?
      self.current_user = @user

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
    respond_to do |f|
      if @current_user.update_attributes(params[:user])
        I18n.locale = @current_user.language
        flash[:success] = t('users.update.updated')
        f.html { redirect_to account_settings_path }
      else
        flash[:error] = t('users.update.error')
        f.html { render 'edit' }
      end
    end

  end

  def unconfirmed_email
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

  def close_welcome
    @current_user.update_attribute(:welcome,true)
    respond_to do |format|
      format.html { redirect_to projects_path }
    end
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
end
