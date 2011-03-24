class OauthController < ApplicationController
  include Oauth::Controllers::ApplicationControllerMethods
  
  skip_before_filter :login_required, :load_project, :rss_token, :recent_projects, :touch_user, :verify_authenticity_token, :add_chrome_frame_header
  Oauth2Token = ::Oauth2Token
  
  before_filter :login_required, :only => [:authorize,:revoke]
  oauthenticate :only => [:test_request]
  oauthenticate :strategies => :token, :interactive => false, :only => [:capabilities]
  oauthenticate :strategies => :two_legged, :interactive => false, :only => [:request_token]
  skip_before_filter :verify_authenticity_token, :only=>[:test_request]
  
  def token
    @client_application = ClientApplication.find_by_key params[:client_id]
    if @client_application.secret != params[:client_secret]
      oauth2_error "invalid_client"
      return
    end
    if ["authorization_code","password"].include?(params[:grant_type])
      send "oauth2_token_#{params[:grant_type].underscore}"
    else
      oauth2_error "unsupported_grant_type"
    end
  end

  def test_request
    render :text => params.collect{|k,v|"#{k}=#{v}"}.join("&")
  end

  def authorize
    if ["code","token"].include?(params[:response_type]) # pick flow
      send "oauth2_authorize_#{params[:response_type]}"
    end
  end

  def revoke
    @token = current_user.tokens.find_by_token params[:token]
    if @token
      @token.invalidate!
      flash[:notice] = "You've revoked the token for #{@token.client_application.name}"
    end
    redirect_to oauth_clients_url
  end
  
  # Capabilities of current_token
  def capabilities
    if current_token.respond_to?(:capabilities)
      @capabilities=current_token.capabilities
    else
      @capabilities={:invalidate=>url_for(:action=>:invalidate)}
    end
    
    respond_to do |format|
      format.json {render :json=>@capabilities}
      format.xml {render :xml=>@capabilities}
    end
  end

  protected

  def oauth2_authorize_code
    @client_application = ClientApplication.find_by_key params[:client_id]
    @oauth_scopes = user_scope
    if request.post?
      @redirect_url = URI.parse(params[:redirect_uri] || @client_application.callback_url)
      if user_authorizes_token?
        @verification_code = Oauth2Verifier.create :client_application=>@client_application, :user=>current_user, :callback_url=>@redirect_url.to_s, :scope=>@oauth_scopes

        unless @redirect_url.to_s.blank?
          @redirect_url.query = @redirect_url.query.blank? ?
                                @verification_code.to_fragment_params(:include => [:code]) :
                                @redirect_url.query + '&' + @verification_code.to_fragment_params(:include => [:code])
          redirect_to @redirect_url.to_s
        else
          render :action => "authorize_success"
        end
      else
        unless @redirect_url.to_s.blank?
          @redirect_url.query = @redirect_url.query.blank? ?
                                "error=user_denied" :
                                @redirect_url.query + "&error=user_denied"
          redirect_to @redirect_url.to_s
        else
          render :action => "authorize_failure"
        end
      end
    else
      render :action => "authorize"
    end
  end

  def oauth2_authorize_token
    @client_application = ClientApplication.find_by_key params[:client_id]
    @oauth_scopes = user_scope
    if request.post?
      @redirect_url = URI.parse(params[:redirect_uri] || @client_application.callback_url)
      if user_authorizes_token?
        @token = Oauth2Token.create :client_application=>@client_application, :user=>current_user, :scope=>@oauth_scopes
        unless @redirect_url.to_s.blank?
          redirect_to "#{@redirect_url.to_s}##{@token.to_fragment_params(:include => [:access_token])}"
        else
          render :action => "authorize_success"
        end
      else
        unless @redirect_url.to_s.blank?
          @redirect_url.query = @redirect_url.query.blank? ?
                                "error=user_denied" :
                                @redirect_url.query + "&error=user_denied"
          redirect_to @redirect_url.to_s
        else
          render :action => "authorize_failure"
        end
      end
    else
      render :action => "authorize"
    end
  end

  # http://tools.ietf.org/html/draft-ietf-oauth-v2-08#section-4.1.1
  def oauth2_token_authorization_code
    @verification_code = @client_application.oauth2_verifiers.find_by_token params[:code]
    unless @verification_code && @verification_code.authorized?
      oauth2_error
      @verification_code.destroy if @verification_code
      return
    end
    if @verification_code.redirect_url != params[:redirect_uri]
      oauth2_error
      return
    end
    @verification_code.scope = @verification_code.scope & user_scope if params[:scope]
    @token = @verification_code.exchange!
    render :json=>@token, :include => [:access_token] 
  end

  # http://tools.ietf.org/html/draft-ietf-oauth-v2-08#section-4.1.2
  def oauth2_token_password
    @user = authenticate_user(params[:username], params[:password])
    unless @user
      oauth2_error
      return
    end
    @token = Oauth2Token.create :client_application=>@client_application, :user=>@user, :scope=>user_scope
    render :json=>@token, :include => [:access_token]
  end
  
  # should authenticate and return a user if valid password. Override in your own controller
  def authenticate_user(username,password)
    User.authenticate(username,password)
  end
  
  def user_scope
    (params[:scope]||'').split(' ').map(&:to_sym) & OauthToken::ALLOWED_SCOPES
  end

  # Override this to match your authorization page form
  def user_authorizes_token?
    params[:authorize] == '1'
  end  

  def oauth2_error(error="invalid_grant")
    render :json=>{:error=>error}.to_json, :status => 401
  end
end
