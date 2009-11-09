class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  before_filter :find_user, :only => [ :show, :confirm_email, :login_from_reset_password ]
  before_filter :load_invitation, :only => [ :new, :create ]
  skip_before_filter :login_required,  :only => [ :new, :create, :confirm_email, :forgot_password, :reset_password, :login_from_reset_password ]
  skip_before_filter :confirmed_user?, :only => [ :new, :create, :confirm_email, :forgot_password, :reset_password, :login_from_reset_password, :unconfirmed_email ]
  skip_before_filter :load_project
  
  def index
  end

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
    @visible_activities = @user.activities_visible_to_user @current_user
    options = { :only => [:id, :login, :name, :language, :email, 'time-zone', 'created-at', 'updated-at'] }
    respond_to do |format|
      format.html
      format.xml { render :xml => @user.to_xml(options) }
      format.json { render :json => @user.to_json(options) }
    end
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.confirmed_user = true if @invitation and @invitation.email == @user.email

    success = @user and @user.save
    if success and @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in

      if @invitation
        person = @invitation.project.people.new(:user => @user, :source_user_id => @invitation.user)
        person.save

        @invitation.destroy
        redirect_to(project_path(@invitation.project))
      else
        redirect_back_or_default('/')
      end
      
      flash[:success] = t('users.create.thanks')
    else
      flash[:error]  = t('users.create.error')
      render :action => :new, :layout => 'sessions'
    end
  end
  
  def update
    @current_user.update_attributes(params[:user])
    if @current_user.save
      flash[:error] = nil
      flash[:success] = t('users.update.updated')
    else
      flash[:success] = nil
      flash[:error] = t('users.update.error')
    end
    render :action => :edit
  end
  
  def unconfirmed_email
    if params[:resend]
      current_user.send_activation_email
      flash[:success] = t('users.activation.resent')
    end

    @email = current_user.email
    render :layout => 'action_required'
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
      flash[:error] = t('users.invalid_user')
    end
    redirect_to '/'
  end

  def forgot_password
    render :layout => 'sessions'
  end
  
  def reset_password
    if params[:email]
      if @user = User.find_by_email(params[:email])
        @user.send_reset_password
        render :layout => 'sessions'
      else
        flash[:error] = t('users.reset_password.not_found', :email => params[:email])
        redirect_to forgot_password_path
      end
    else
      redirect_to forgot_password_path
    end
  end

  def login_from_reset_password
    logout_keeping_session!
    if @user && @user.is_login_token_valid?(params[:token])
      @user.activate!
      @user.expire_login_code!
      self.current_user = @user
      redirect_to edit_user_path(@user)
      flash[:success] = t('users.reset_password.chage_password_now')
      flash[:change_password] = true
    else
      flash[:error] = t('users.activation.invalid_user')
      redirect_to '/'
    end
  end
  
  def contact_importer
  end

  def comments_ascending
    @current_user.update_attribute(:comments_ascending,true)

    respond_to do |format|
      format.js
    end
  end

  def comments_descending
    @current_user.update_attribute(:comments_ascending,false)

    respond_to do |format|
      format.js
    end
  end
  
  def conversations_first_comment
    @current_user.update_attribute(:conversations_first_comment,true)

    respond_to do |format|
      format.js
    end
  end

  def conversations_latest_comment
    @current_user.update_attribute(:conversations_first_comment,false)

    respond_to do |format|
      format.js
    end
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
      unless @user = User.find_by_id(params[:id])
        flash[:error] = "Unexisting user"
        redirect_to '/'
      end
    end
    
    def load_invitation
      if params[:invitation]
        @invitation = Invitation.find_by_token(params[:invitation])
        @invitation_token = params[:invitation] if @invitation
      end
    end

end
