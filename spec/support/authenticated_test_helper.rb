module AuthenticatedTestHelper
  protected

  def login_as(user, *args)
    user = Factory.create(user, *args) unless user.nil? or user.is_a? User
    session[:user_id] = user ? user.id : nil
    user
  end
  
  def login_as_with_oauth_scope(user, scope)
    user = Factory.create(user, *args) unless user.nil? or user.is_a? User
    app = ClientApplication.first || Factory.create(:client_application)
    user.current_token = OauthToken.find_by_user_id(user.id) || Oauth2Token.create!(:user=>user,:client_application=>app,:scope => scope)
    user.current_token.scope = scope
    user.current_token.save
    user
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'monkey') : nil
  end
  
end
