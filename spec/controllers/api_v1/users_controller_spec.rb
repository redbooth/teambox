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
    it "should return the current api version" do
      login_as @fred
      
      get :current
      response.headers['X-Tbox-Version'].should == ApiV1::APIController::API_VERSION
    end
    
    it "should get the current user for oauth requests" do
      @token = access_token

      get :current, :access_token => @token.token
      response.should be_success

      data = JSON.parse(response.body)['id'].to_i.should == @token.user_id
    end

    it "should not get the current user for expired oauth requests" do
      @token = access_token
      @token.update_attribute(:valid_to, Time.now - 2.days)

      get :current, :access_token => @token.token
      response.status.should == 401
    end
  end
  
  describe "#create" do
    it "should create a user" do
      do_create
      response.should be_success
      
      data = JSON.parse(response.body)
      
      data['type'].should == 'User'
      user = User.find_by_id(data['id'])
      user.login.should == 'testing'
      user.email.should == 'testing@localhost.com'
    end
    
    it "should not create an invalid user" do
      do_create :email => 'a'
      response.should_not be_success
      
      data = JSON.parse(response.body)
      
      data['errors'].should_not == nil
    end
  end
  
  describe "#update" do
    it "should update the specified user" do
      login_as @user
      
      put :update, :id => @user.id, :first_name => 'Lololol'
      response.should be_success
      
      @user.reload.first_name.should == 'Lololol'
    end
    
    it "should not modify other users" do
      login_as @user
      
      put :update, :id => @fred.id, :first_name => 'Lololol'
      response.should_not be_success
      
      @fred.reload.first_name.should_not == 'Lololol'
    end
  end
  
  def do_create(options = {})
    post :create, { :email       => 'testing@localhost.com',
                    :login       => 'testing',
                    :first_name  => 'Andrew',
                    :last_name   => 'Wiggin',
                    :password    => 'testing',
                    :password_confirmation => 'testing'}.merge(options)
  end
end
