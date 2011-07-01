class ApiV2::APIController < ActionController::Base
  include AuthenticatedSystem
  include Oauth::Controllers::ApplicationControllerMethods
  Oauth2Token = ::Oauth2Token

  before_filter :set_client, :load_project, :api_login

  protected

  rescue_from CanCan::AccessDenied do |exception|
    head(:unauthorized)
  end

  def set_client
    request.format = :json unless request.format == :js
  end

  def load_project
    if params[:project_id]
      @current_project = Project.find_by_id_or_permalink(params[:project_id])
    end
  end

  def api_limit(options = {})
    count = params[:count] && params[:count].to_i
    return [count && count > 0 ? count : api_max_limit, api_max_limit].min if options[:hard]
    if count
      count == 0 ? nil : count
    else
      api_max_limit
    end
  end


  def api_range(table_name)
    since_id = params[:since_id]
    max_id = params[:max_id]

    if since_id and max_id
      ["#{table_name}.id > ? AND #{table_name}.id < ?", since_id, max_id]
    elsif since_id
      ["#{table_name}.id > ?", since_id]
    elsif max_id
      ["#{table_name}.id < ?", max_id]
    else
      []
    end
  end

  def current_user
    @current_user ||= (login_from_session ||
                       login_from_basic_auth ||
                       login_from_cookie ||
                       login_from_oauth) unless @current_user == false
  end

  def login_from_oauth
    user = Authenticator.new(self,[:token]).allow? ? current_token.user : nil
    user.current_token = current_token if user
    user
  end

  def api_login
    head(:unauthorized) unless current_user
  end

  private
  def api_max_limit
    @api_max_limit ||= Rails.env.test? ? 10 : 20
  end
end

