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
      users_found = JSON.parse(response.body).map{|u|u['id'].to_i}.sort

      users_found.should == users_expected
      users_found.include?(@owner.id).should == true
      users_found.include?(other_project.user.id).should_not == true
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
      response.status.should == '401 Unauthorized'
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
  end
end