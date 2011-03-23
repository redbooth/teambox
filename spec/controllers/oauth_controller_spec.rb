require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/oauth_controller_spec_helper'
require 'json'
describe OauthController do
  if defined?(Devise)
    include Devise::TestHelpers
  end
  include OAuthControllerSpecHelper
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
        response.should render_template("oauth2_authorize")
      end

      it "should not create token" do
        Oauth2Verifier.last.should be_nil
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
        response.should redirect_to("http://application/callback?code=#{@verification_token.code}")
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

        it "should set user to current user" do
          @token.user.should==current_user
        end

        it "should return json token" do
          JSON.parse(response.body).should=={"access_token"=>@token.token}
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
        response.should render_template("oauth2_authorize")
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
        response.should redirect_to("http://application/callback#access_token=#{@token.token}")
      end

      it "should not have a scope" do
        @token.scope.should be_nil
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

  describe "oauth2 token for autonomous client_application" do
    before(:each) do
      current_client_application
      @oauth2_token_count = Oauth2Token.count
      post :token, :grant_type=>"none", :client_id=>current_client_application.key,:client_secret=>current_client_application.secret
      @token = Oauth2Token.last
    end

    subject { @token }

    it { should_not be_nil }
    it { should be_authorized }
    it "should set user to client_applications user" do
      @token.user.should==current_client_application.user
    end
    it "should have added a new token" do
      Oauth2Token.count.should==@oauth2_token_count+1
    end

    it "should return json token" do
      JSON.parse(response.body).should=={"access_token"=>@token.token}
    end
  end

  describe "oauth2 token for autonomous client_application with invalid client credentials" do
    before(:each) do
      current_client_application
      @oauth2_token_count = Oauth2Token.count
      post :token, :grant_type=>"none", :client_id=>current_client_application.key,:client_secret=>"bad"
    end

    subject { @token }

    it "should not have added a new token" do
      Oauth2Token.count.should==@oauth2_token_count
    end

    it "should return json token" do
      JSON.parse(response.body).should=={"error"=>"invalid_client"}
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
      JSON.parse(response.body).should=={"access_token"=>@token.token}
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


