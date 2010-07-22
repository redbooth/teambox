require 'spec_helper'

describe ApiV1::PeopleController do
  before do
    @user = Factory.create(:confirmed_user)
    @user2 = Factory.create(:confirmed_user)
    @project = Factory.create(:project)
    @owner = @project.user
    @project.add_user(@user)
    @project.people(true).last.update_attribute(:role, Person::ROLES[:admin])
    @project.add_user(@user2)
  end
  
  describe "#index" do
    it "shows people in the project" do
      login_as @user2
      
      get :index, :project_id => @project.permalink, :id => @project.people.first.id
      response.should be_success
      
      JSON.parse(response.body)['people'].length.should == 3
    end
  end
  
  describe "#show" do
    it "shows a person" do
      login_as @user2
      
      get :show, :project_id => @project.permalink, :id => @project.people.first.id
      response.should be_success
    end
  end
  
  describe "#update" do
    it "should allow an admin to modify a person" do
      login_as @user
      
      post :update, :project_id => @project.permalink, :id => @project.people.last.id, :person => {:role => Person::ROLES[:admin]}
      response.should be_success
      
      @project.reload.admin?(@user2).should == true
    end
    
    it "should not allow the owner to be modified" do
      login_as @user
      
      post :update, :project_id => @project.permalink, :id => @project.people.first.id, :person => {:role => Person::ROLES[:participant]}
      response.status.should == '422 Unprocessable Entity'
      
      @project.reload.admin?(@owner).should == true
    end
    
    it "should not allow a non-admin to modify a person" do
      login_as @user2
      
      post :update, :project_id => @project.permalink, :id => @project.people.last.id, :person => {:role => Person::ROLES[:admin]}
      response.status.should == '401 Unauthorized'
      
      @project.reload.admin?(@user2).should == false
    end
  end
  
  describe "#destroy" do
    it "should allow an admin to destroy a person" do
      login_as @user2
      
      post :destroy, :project_id => @project.permalink, :id => @project.people.last.id
      response.should be_success
      
      @project.people(true).length.should == 2
    end
    
    it "should not allow an owner to remove themselves from the project" do
      login_as @owner
      
      post :destroy, :project_id => @project.permalink, :id => @project.people.first.id
      response.status.should == '401 Unauthorized'
      
      @project.people(true).length.should == 3
    end
    
    it "should allow a user to remove themselves from the project" do
      login_as @user2
      
      post :destroy, :project_id => @project.permalink, :id => @project.people[2].id
      response.should be_success
      
      @project.people(true).length.should == 2
    end
    
    it "should not allow a non-admin to destroy another person" do
      login_as @user2
      
      post :destroy, :project_id => @project.permalink, :id => @project.people[1].id
      response.status.should == '401 Unauthorized'
      
      @project.people(true).length.should == 3
    end
  end
end