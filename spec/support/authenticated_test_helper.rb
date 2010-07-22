module AuthenticatedTestHelper
  protected

  def login_as(user, *args)
    user = Factory.create(user, *args) unless user.nil? or user.is_a? User
    session[:user_id] = user ? user.id : nil
    user
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'monkey') : nil
  end
  
end
