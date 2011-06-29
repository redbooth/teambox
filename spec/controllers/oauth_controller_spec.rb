require 'spec_helper'
require 'json'

describe OauthController do
  fixtures :oauth_tokens

  describe "2.0 authorization code flow" do
    before(:each) do
      login
    end

    describe "authorize redirect" do
      before(:each) do
        get :authorize, :response_type=>"code",:client_id=>current_client_application.key, :redirect_uri=>"http://application/callback"
      end

      it "should render authorize" do
        response.should render_template("authorize")
      end

      it "should not create token" do
        Oauth2Verifier.last.should be_nil
      end
    end
    
    describe "authorize invalid client" do
      it "should render a failure page if an invalid client is used" do
        get :authorize, :response_type=>"code",:client_id=>'000', :redirect_uri=>"http://application/callback"
        response.body.should == 'Invalid Application Key'
      end
    end
    
    describe "authorize invalid response type" do
      it "should render a failure page if an invalid response type is used" do
        get :authorize, :response_type=>"fudge",:client_id=>current_client_application.key, :redirect_uri=>"http://application/callback"
        response.body.should == 'Invalid Request'
      end
    end

    describe "authorize" do
      before(:each) do
        post :authorize, :response_type=>"code",:client_id=>current_client_application.key, :redirect_uri=>"http://application/callback",:authorize=>"1"
        @verification_token = Oauth2Verifier.last
        @oauth2_token_count= Oauth2Token.count
      end
      subject { @verification_token }

      it { should_not be_nil }
      it "should set user on verification token" do
        @verification_token.user.should==current_user
      end

      it "should set redirect_url" do
        @verification_token.redirect_url.should == "http://application/callback"
      end

      it "should redirect to default callback" do
        response.should be_redirect
        uri = URI.parse(response.redirect_url)
        query = Rack::Utils.parse_query(uri.query)
        uri.host.should == 'application'
        uri.path.should == '/callback'
        query['code'].should == @verification_token.code
      end

      describe "get token" do
        before(:each) do
          post :token, :grant_type=>"authorization_code", :client_id=>current_client_application.key,:client_secret=>current_client_application.secret, :redirect_uri=>"http://application/callback",:code=>@verification_token.code
          @token = Oauth2Token.last
        end

        subject { @token }

        it { should_not be_nil }
        it { should be_authorized }
        it "should have added a new token" do
          Oauth2Token.count.should==@oauth2_token_count+1
        end
        
        it "should have cleared the verification token" do
          Oauth2Verifier.find_by_token(@verification_token.token).should == nil
        end

        it "should set user to current user" do
          @token.user.should==current_user
        end

        it "should return json token" do
          data = JSON.parse(response.body)
          data["access_token"].should==@token.token
        end
      end
      
      describe "get token with the same verifier twice fails" do
        before(:each) do
          post :token, :grant_type=>"authorization_code", :client_id=>current_client_application.key,:client_secret=>current_client_application.secret, :redirect_uri=>"http://application/callback",:code=>@verification_token.code
          post :token, :grant_type=>"authorization_code", :client_id=>current_client_application.key,:client_secret=>current_client_application.secret, :redirect_uri=>"http://application/callback",:code=>@verification_token.code
        end

        it "should return incorrect_client_credentials error" do
          JSON.parse(response.body).should == {"error"=>"invalid_grant"}
        end
      end
      
      describe "get token twice destroys existing access tokens" do
        before(:each) do
          post :token, :grant_type=>"authorization_code", :client_id=>current_client_application.key,:client_secret=>current_client_application.secret, :redirect_uri=>"http://application/callback",:code=>@verification_token.code
          @token = Oauth2Token.last
          post :authorize, :response_type=>"code",:client_id=>current_client_application.key, :redirect_uri=>"http://application/callback",:authorize=>"1"
          @verification_token = Oauth2Verifier.last
          post :token, :grant_type=>"authorization_code", :client_id=>current_client_application.key,:client_secret=>current_client_application.secret, :redirect_uri=>"http://application/callback",:code=>@verification_token.code
          @new_token = Oauth2Token.last
        end

        it "should generate a new token" do
          response.should be_success
          @token.id.should_not == @new_token.id
        end
        
        it "should destroy the old token" do
          Oauth2Token.find_by_id(@token.id).should == nil
          Oauth2Token.find_by_id(@new_token.id).should_not == nil
        end
      end

      describe "get token with wrong secret" do
        before(:each) do
          post :token, :grant_type=>"authorization_code", :client_id=>current_client_application.key,:client_secret=>"fake", :redirect_uri=>"http://application/callback",:code=>@verification_token.code
        end

        it "should not create token" do
          Oauth2Token.count.should==@oauth2_token_count
        end

        it "should return incorrect_client_credentials error" do
          JSON.parse(response.body).should == {"error"=>"invalid_client"}
        end
      end

      describe "get token with wrong code" do
        before(:each) do
          post :token, :grant_type=>"authorization_code", :client_id=>current_client_application.key,:client_secret=>current_client_application.secret, :redirect_uri=>"http://application/callback",:code=>"fake"
        end

        it "should not create token" do
          Oauth2Token.count.should==@oauth2_token_count
        end

        it "should return incorrect_client_credentials error" do
          JSON.parse(response.body).should == {"error"=>"invalid_grant"}
        end
      end

      describe "get token with wrong redirect_url" do
        before(:each) do
          post :token, :grant_type=>"authorization_code", :client_id=>current_client_application.key,:client_secret=>current_client_application.secret, :redirect_uri=>"http://evil/callback",:code=>@verification_token.code
        end

        it "should not create token" do
          Oauth2Token.count.should==@oauth2_token_count
        end

        it "should return incorrect_client_credentials error" do
          JSON.parse(response.body).should == {"error"=>"invalid_grant"}
        end
      end

    end

    describe "scopes on authorize" do
      def auth_with_scope(scope)
        post :authorize, :response_type=>"code",:client_id=>current_client_application.key, :redirect_uri=>"http://application/callback",:authorize=>"1", :scope => scope
        @verification_token = Oauth2Verifier.last
      end
      
      it "should only allow OauthToken::ALLOWED_SCOPES" do
        auth_with_scope("offline_access github")
        post :token, :grant_type=>"authorization_code", :client_id=>current_client_application.key,:client_secret=>current_client_application.secret, :redirect_uri=>"http://application/callback",:code=>@verification_token.code
        @token = Oauth2Token.last
        @token.scope.should == [:offline_access]
      end
      
      it "should allow the scope to be further restricted on token" do
        auth_with_scope("offline_access read_projects")
        post :token, :grant_type=>"authorization_code", :client_id=>current_client_application.key,:client_secret=>current_client_application.secret, :redirect_uri=>"http://application/callback",:code=>@verification_token.code, :scope => "read_projects write_projects"
        @token = Oauth2Token.last
        @token.scope.should == [:read_projects]
      end
      
    end
    
    describe "redirect_uri on authorize" do
      def auth_with_redirect(url)
        post :authorize, :response_type=>"code",:client_id=>current_client_application.key, :redirect_uri=>url,:authorize=>"1"
        @verification_token = Oauth2Verifier.last
      end
      
      it "should not allow a blank uri" do
        post :authorize, :response_type=>"code",:client_id=>current_client_application.key, :authorize=>"1"
        response.should be_redirect
        uri = URI.parse(response.redirect_url)
        query = Rack::Utils.parse_query(uri.query)
        uri.host.should == 'application'
        uri.path.should == '/callback'
        query['error'].should == 'redirect_uri_mismatch'
      end
      
      it "should allow http://application/callback" do
        auth_with_redirect("http://application/callback")
        response.should be_redirect
      end
      
      it "should not allow http://other-application/callback" do
        auth_with_redirect("http://other-application/callback")
        uri = URI.parse(response.redirect_url)
        query = Rack::Utils.parse_query(uri.query)
        uri.host.should == 'application'
        uri.path.should == '/callback'
        query['error'].should == 'redirect_uri_mismatch'
      end
      
      it "should not allow http://other-application/callback on GET" do
        get :authorize, :response_type=>"code", :client_id=>current_client_application.key, :redirect_uri => 'http://other-application/callback'
        response.body.should == 'Invalid Redirect URI'
      end
    end
    
    describe "deny" do
      before(:each) do
        post :authorize, :response_type=>"code", :client_id=>current_client_application.key, :redirect_uri=>"http://application/callback",:authorize=>"0"
      end

      it { Oauth2Verifier.last.should be_nil }

      it "should redirect to default callback" do
        response.should be_redirect
        response.should redirect_to("http://application/callback?error=user_denied")
      end
    end

  end


  describe "2.0 authorization token flow" do
    before(:each) do
      login
      current_client_application # load up so it creates its own token
      @oauth2_token_count= Oauth2Token.count
    end

    describe "authorize redirect" do
      before(:each) do
        get :authorize, :response_type=>"token",:client_id=>current_client_application.key, :redirect_uri=>"http://application/callback"
      end

      it "should render authorize" do
        response.should render_template("authorize")
      end

      it "should not create token" do
        Oauth2Verifier.last.should be_nil
      end
    end

    describe "authorize" do
      before(:each) do
        post :authorize, :response_type=>"token",:client_id=>current_client_application.key, :redirect_uri=>"http://application/callback",:authorize=>"1"
        @token = Oauth2Token.last
      end
      subject { @token }
      it "should redirect to default callback" do
        response.should be_redirect
        response.should redirect_to("http://application/callback##{@token.to_fragment_params}")
      end

      it "should not have a scope" do
        @token.scope.should be_empty
      end
      it { should_not be_nil }
      it { should be_authorized }

      it "should set user to current user" do
        @token.user.should==current_user
      end

      it "should have added a new token" do
        Oauth2Token.count.should==@oauth2_token_count+1
      end
    end

    describe "deny" do
      before(:each) do
        post :authorize, :response_type=>"token", :client_id=>current_client_application.key, :redirect_uri=>"http://application/callback",:authorize=>"0"
      end

      it { Oauth2Verifier.last.should be_nil }

      it "should redirect to default callback" do
        response.should be_redirect
        response.should redirect_to("http://application/callback?error=user_denied")
      end
    end
  end

  describe "oauth2 token for basic credentials" do
    before(:each) do
      current_client_application
      @oauth2_token_count = Oauth2Token.count
      current_user.should_not == nil
      post :token, :grant_type=>"password", :client_id=>current_client_application.key,:client_secret=>current_client_application.secret, :username=>current_user.login, :password=>"dragons"
      @token = Oauth2Token.last
    end

    it { @token.should_not be_nil }
    it { @token.should be_authorized }
    
    it "should set user to client_applications user" do
      @token.user.should==current_user
    end
    it "should have added a new token" do
      Oauth2Token.count.should==@oauth2_token_count+1
    end

    it "should return json token" do
      data = JSON.parse(response.body)
      data["access_token"].should==@token.token
    end
  end

  describe "oauth2 token for basic credentials with wrong password" do
    before(:each) do
      current_client_application
      @oauth2_token_count = Oauth2Token.count
      post :token, :grant_type=>"password", :client_id=>current_client_application.key,:client_secret=>current_client_application.secret, :username=>current_user.login, :password=>"bad"
    end

    it "should not have added a new token" do
      Oauth2Token.count.should==@oauth2_token_count
    end

    it "should return json token" do
      JSON.parse(response.body).should=={"error"=>"invalid_grant"}
    end
  end

  describe "oauth2 token for basic credentials with unknown user" do
    before(:each) do
      current_client_application
      @oauth2_token_count = Oauth2Token.count
      post :token, :grant_type=>"password", :client_id=>current_client_application.key,:client_secret=>current_client_application.secret, :username=>"non existent", :password=>"dragons"
    end

    it "should not have added a new token" do
      Oauth2Token.count.should==@oauth2_token_count
    end

    it "should return json token" do
      JSON.parse(response.body).should=={"error"=>"invalid_grant"}
    end
  end

end


