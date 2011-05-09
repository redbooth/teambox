require File.dirname(__FILE__) + '/../spec_helper'

describe Oauth2Token do
  fixtures :oauth_tokens
  
  describe "By default..." do
    before(:each) do
      @token = Oauth2Token.create :client_application => Factory.create(:client_application), :user => Factory.create(:user)
    end

    it "should be valid" do
      @token.should be_valid
    end

    it "should have a token" do
      @token.token.should_not be_nil
    end

    it "should have a secret" do
      @token.secret.should_not be_nil
    end

    it "should be authorized" do
      @token.should be_authorized
    end

    it "should not be invalidated" do
      @token.should_not be_invalidated
    end
  end
  
  describe "Using scopes..." do
    it "should generate a token which expires when created" do
      @token = Oauth2Token.create :client_application => Factory.create(:client_application), :user => Factory.create(:user), :scope => []
      @token.valid_to.should_not == nil
    end
  
    it "should generate a token which does not expire when created with the :offline_access scope" do
      @token = Oauth2Token.create :client_application => Factory.create(:client_application), :user => Factory.create(:user), :scope => [:offline_access]
      @token.valid_to.should == nil
    end
  end

end
