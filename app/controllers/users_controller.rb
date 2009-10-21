class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  before_filter :find_user, :only => [ :show, :confirm_email ]
  before_filter :load_invitation, :only => [ :new, :create ]
  skip_before_filter :login_required, :only => [ :new, :create, :confirm_email ]
  skip_before_filter :load_project
  skip_before_filter :confirmed_user?, :only => [ :new, :create, :unconfirmed_email, :confirm_email ]  
  
  def index
  end

  def new
    if logged_in?
      flash[:success] = "You already have an account. Log out first to sign up as a different user."
      redirect_to projects_path
    else
      @user = User.new
      render :layout => 'login'
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
    success = @user and @user.save
    if success and @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in

      unless @invitation.nil?
        person = @invitation.project.people.new(:user => @user, :source_user_id => @invitation.user)
        person.save
        @invitation.destroy
        redirect_to(project_path(@invitation.project))
      else
        redirect_back_or_default('/')
      end
      
      flash[:notice] = "Thanks for signing up!"
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => :new, :layout => 'login'
    end
  end
  
  def update
    @current_user.update_attributes(params[:user])
    if @current_user.save
      flash[:error] = nil
      flash[:success] = "User profile updated!"
    else
      flash[:success] = nil
      flash[:error] = "Couldn't save the updated profile. Please correct the mistakes and retry."
    end
    render :action => :edit
  end
  
  def unconfirmed_email
    if params[:resend]
      current_user.send_confirm_email
      flash[:success] = "We've re-sent the activation email. Take a look at your inbox!"
    end

    @email = current_user.email
    render :layout => 'action_required'
  end
  
  def confirm_email
    logout_keeping_session!
    if @user
      if @user.is_login_token_valid? params[:token]
        if @user.confirmed_user
          flash[:success] = "You had already confirmed your email! You can now use Teambox."
        else
          flash[:success] = "Your account has been activated! Welcome to Teambox :)"
          @user.confirm_email
          self.current_user = @user
        end
      else
        flash[:error] = "<p>Invalid or expired access link. Login with your email and password.</p><p>If you don't remember your login data, follow the Forgot your Password link.</p>"
      end
    else
      flash[:error] = "Invalid user"
    end
    redirect_to '/'
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
  
  def invitations
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
      @user = User.find_by_id(params[:id])
    end
    
    def load_invitation
      unless params[:invitation].nil?
        @invitation = Invitation.find_by_token(params[:invitation])
        unless @invitation.nil?
          @invitation_token = params[:invitation]
        end
      end
    end

end
