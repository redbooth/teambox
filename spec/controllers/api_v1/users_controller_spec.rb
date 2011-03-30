require 'spec_helper'

describe ApiV1::UsersController do
  before do
    @user = Factory.create(:confirmed_user)
    @fred = Factory.create(:confirmed_user)
    @project = Factory.create(:project)
    @owner = @project.user
    @project.add_user(@user)
  end
  
  describe "#index" do
    it "shows all users known to the current user" do
      login_as @user
      other_project = Factory.create(:project)
      
      get :index
      response.should be_success

      users_expected = @user.users_with_shared_projects.map(&:id).sort
      users_found = JSON.parse(response.body)['objects'].map{|u|u['id'].to_i}.sort

      users_found.should == users_expected
      users_found.include?(@owner.id).should == true
      users_found.include?(other_project.user.id).should_not == true
    end
    
    it "limits all users known to the current user" do
      login_as @user
      other_project = Factory.create(:project)
      
      get :index, :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 1
    end
    
    it "limits and offsets users known to the current user" do
      login_as @user
      other_project = Factory.create(:project)
      
      get :index, :count => 1, :since_id => @user.users_with_shared_projects.map(&:id)[0]
      response.should be_success

      JSON.parse(response.body)['objects'].map{|m|m['id'].to_i}.should == [@user.users_with_shared_projects.map(&:id)[1]]
    end
  end
  
  describe "#show" do
    it "shows a user by name" do
      login_as @user
      
      get :show, :id => @project.user.login
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @project.user.id
    end
    
    it "shows a user by id" do
      login_as @user
      
      get :show, :id => @project.user.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @project.user.id
    end
    
    it "does not show a user not known to the current user" do
      login_as @user
      
      get :show, :id => @fred.login
      response.status.should == 401
    end
  end
  
  describe "#current" do
    it "shows the current user" do
      login_as @user
      
      get :current
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @user.id
    end
    
    it "really shows the current user" do
      login_as @fred
      
      get :current
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @fred.id
    end
    
    it "fails if you are not logged in" do
      get :current
      response.status.should == 401
      
      JSON.parse(response.body)['errors']['type'].should == 'AuthorizationFailed'
    end
  end
  
  describe "#current" do
    it "should get the current user for oauth requests" do
      @token = access_token
      
      get :current, :access_token => @token.token
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @token.user_id
    end
    
    it "should not get the current user for expired oauth requests" do
      @token = access_token
      @token.update_attribute(:valid_to, Time.now - 2.days)
      
      get :current, :access_token => @token.token
      response.status.should == 401
    end
  end
end