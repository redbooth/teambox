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
      if session[:app_link_id] and app_link = AppLink.find_by_id(session[:app_link_id])
        signup_from_oauth(app_link)
        @conflict = true if app_link.sign_up_conflict?
        @provider = app_link.provider.humanize
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
    @activities = Activity.for_projects(@user.projects_shared_with(@current_user)).from_user(@user).
      where(['is_private = ? OR (is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
      joins("LEFT JOIN watchers ON ((activities.comment_target_id = watchers.watchable_id AND watchers.watchable_type = activities.comment_target_type) OR (activities.target_id = watchers.watchable_id AND watchers.watchable_type = activities.target_type)) AND watchers.user_id = #{current_user.id}")
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
      end
    end
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    if session[:app_link_id] and app_link = AppLink.find_by_id(session[:app_link_id])
      app_link_email = app_link.detect_custom_attribute { |k,v| k == 'email' }
    end

    @user.confirmed_user = (
      (@invitation && @invitation.email == @user.email) or
      (app_link_email && app_link_email == @user.email) or
      !Teambox.config.email_confirmation_require)

    if @user && @user.save
      self.current_user = @user

      if app_link
        app_link.user = @user
        app_link.save
      end

      if @invitation
        # Can be an invitation to a project or just to Teambox
        if @invitation.project
          redirect_to project_path(@invitation.project)
        else
          redirect_to projects_path
        end
      else
        # If the form sent a parameter for org's name,
        # we will create an organization and project
        name = params[:user][:organization][:name] rescue nil
        project = create_initial_organization_and_project(name)

        redirect_to project ? project_invite_people_path(project) : root_path
      end
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

  def email_posts
    @project_permalink = params[:project_permalink]||''
    @target_type = params[:target_type]||''
    @target_id = params[:target_id]||''
    render :layout => false
  end

  def calendars
    oauth_info = Teambox.config.providers.detect { |p| p.provider == 'google' }
    if oauth_info.nil?
      Rails.logger.debug "There is no Google provider cannot list calendars"
      return true
    end
    consumer = OAuth::Consumer.new(oauth_info.key, oauth_info.secret, GoogleCalendar::RESOURCES)
    
    app_link = current_user.app_links.find_by_provider('google')
    if app_link.nil?
      Rails.logger.debug "The user has not linked their Google account, cannot link calendars"
      return true
    end
    
    gcal = GoogleCalendar.new(app_link.credentials['token'], app_link.credentials['secret'], consumer)
    @google_calendars = gcal.list_own
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

  def increment_stat
    key = params[:stat].to_s
    @current_user.increment_stat(key)
    render :text => @current_user.get_stat(key)
  end

  def grant_badge
    @current_user.grant_badge params[:badge]
    head :ok
  end

  def hide_first_steps
    @current_user.write_setting 'show_first_steps', false
    head :ok
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

    def signup_from_oauth(app_link)
      app_link = AppLink.find_by_id session[:app_link_id]
      @user ||= User.new

      @user.first_name    ||= app_link.detect_custom_attribute {|k,v| k == 'first_name' }
      @user.last_name     ||= app_link.detect_custom_attribute {|k,v| k == 'last_name' }

      if @user.first_name.blank? and @user.last_name.blank? and name = app_link.detect_custom_attribute {|k,v| k == 'name' and v.split(' ').size > 1 }
        name = name.split(' ')
        @user.first_name = name.first
        @user.last_name = name.last
      end
      if login = app_link.detect_custom_attribute {|k,v| /(login|username|nickname)/.match(k) }
        @user.login     ||= User.find_available_login(login)
      end
      if locale = app_link.detect_custom_attribute {|k,v| ['locale','lang','language'].include? k }
        @user.locale = locale
      end

      if email = app_link.detect_custom_attribute {|k,v| k == 'email' }
        @user.email     ||= email unless User.find_by_email(email)
      end
    end

    def can_users_signup?
      unless @invitation || signups_enabled?
        flash[:error] = t('users.new.no_public_signup')
        return redirect_to Teambox.config.community ? login_path : root_path
      end
    end

    def create_initial_organization_and_project(name)
      return if (name || "").length <= 1
      begin
        permalink = PermalinkFu.escape(name)
        org = @user.organizations.new(:name => name, :permalink => permalink)
        org.save!
        project = org.projects.new(:name => name, :permalink => permalink)
        project.user = @user
        project.save!
        return project
      rescue
      end
    end
end
