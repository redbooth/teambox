class ApiV1::UsersController < ApiV1::APIController
  no_login_required :only => [ :create ]

  skip_before_filter :confirmed_user?, :only => [ :create ]
  before_filter :find_user, :only => [ :show, :update ]
  before_filter :load_invitation, :only => [ :create ]
  skip_before_filter :load_project
  
  def index
    authorize! :show, current_user
    
    @users = current_user.users_with_shared_projects.
      where(api_range('users')).
      limit(api_limit).
      order('id DESC')
    
    api_respond @users
  end

  def show
    authorize! :show, @user||current_user
    projects_shared = @user.projects_shared_with(@current_user)
    shares_invited_projects = projects_shared.empty? && @user.shares_invited_projects_with?(@current_user)
    
    if @user != @current_user and (!shares_invited_projects and projects_shared.empty?)
      api_error(:unauthorized, :type => 'InsufficientPermissions', :message => t('users.activation.invalid_user'))
    else
      api_respond @user
    end
  end

  def create
    logout_keeping_session!
    @user = User.new(params)

    @user.confirmed_user = (
      (@invitation && @invitation.email == @user.email) or
      !Teambox.config.email_confirmation_require)

    if @user.save
      self.current_user = @user

      handle_api_success(@user, :is_new => true)
    else
      handle_api_error(@user)
    end
  end

  def update
    authorize! :update, @user
    
    if @user.update_attributes(params)
      handle_api_success(@user)
    else
      handle_api_error(@user)
    end
  end

  def current
    api_respond current_user, :include => api_include+[:email], :extra_fields => {:api_version => API_VERSION}
  end

  protected
  
  def find_user
    unless @user = (User.find_by_login(params[:id]) || User.find_by_id(params[:id]))
      api_error(:not_found, :type => 'ObjectNotFound', :message => t('not_found.user'))
    end
  end  

  def load_invitation
    if params[:invitation]
      @invitation = Invitation.find_by_token(params[:invitation])
      @invitation_token = params[:invitation] if @invitation
    end
  end
  
  def api_include
    [:projects, :organizations] & (params[:include]||{}).map(&:to_sym)
  end
  
end
