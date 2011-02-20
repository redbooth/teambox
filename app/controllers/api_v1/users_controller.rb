class ApiV1::UsersController < ApiV1::APIController
  before_filter :find_user, :only => [ :show ]
  skip_before_filter :load_project
  
  def index
    api_respond current_user.users_with_shared_projects, :references => []
  end

  def show
    projects_shared = @user.projects_shared_with(@current_user)
    shares_invited_projects = projects_shared.empty? && @user.shares_invited_projects_with?(@current_user)
    
    if @user != @current_user and (!shares_invited_projects and projects_shared.empty?)
      api_error(:unauthorized, :type => 'InsufficientPermissions', :message => t('users.activation.invalid_user'))
    else
      api_respond @user
    end
  end
  
  def current
    api_respond current_user, :include => api_include+[:email]
  end

  protected
  
  def find_user
    unless @user = (User.find_by_login(params[:id]) || User.find_by_id(params[:id]))
      api_error(:not_found, :type => 'ObjectNotFound', :message => t('not_found.user'))
    end
  end
  
  def api_include
    [:projects, :organizations] & (params[:include]||{}).map(&:to_sym)
  end
  
end