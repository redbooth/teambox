require 'spec_helper'

describe ApiV1::ProjectsController do
  before do
    @user = Factory.create(:confirmed_user)
    @admin = Factory.create(:confirmed_user)
    @project = Factory.create(:project)
    @owner = @project.user
    @project.add_user(@user)
    @project.add_user(@admin)
    @project.people.last.update_attribute(:role, Person::ROLES[:admin])
  end
  
  describe "#index" do
    it "shows projects the user belongs to" do
      login_as @user
      
      get :index
      response.should be_success
      JSON.parse(response.body)['projects'].length.should == 1
    end
    
    it "does not show projects the user doesn't belong to" do
      login_as Factory(:confirmed_user)
      
      get :index
      response.should be_success
      JSON.parse(response.body)['projects'].length.should == 0
    end
  end
  
  describe "#create" do
    it "creates a project with invitations" do
      login_as @user
    
      @user2 = Factory.create(:user)
    
      project_attributes = Factory.attributes_for(:project, :user => nil,
        :invite_users => [@user2.id],
        :invite_emails => "richard.roe@law.uni"
      )

      lambda {
        post :create, :project => project_attributes
        response.status.should == '201 Created'
      }.should change(Project, :count)
    
      project = Project.last(:order => 'id')
      project.should have(2).invitations
    end
  end
  
  describe "#update" do
    it "should allow an admin to update the project" do
      login_as @admin
      
      post :update, :id => @project.permalink, :project => {:permalink => 'ffffuuuuuu'}
      response.should be_success
      
      @project.reload.permalink.should == 'ffffuuuuuu'
    end
    
    it "should not allow a non-admin to update the project" do
      login_as @user
      
      post :update, :id => @project.permalink, :project => {:permalink => 'ffffuuuuuu'}
      response.status.should == '401 Unauthorized'
      
      @project.reload.permalink.should_not == 'ffffuuuuuu'
    end
  end
  
  describe "#transfer" do
    it "should allow the owner to transfer the project" do
      login_as @owner
      
      post :transfer, :id => @project.permalink, :project => {:user_id => @user.id}
      response.should be_success
      
      @project.reload.user.should == @user
    end
    
    it "should not allow non-owners to transfer the project" do
      login_as @user
      
      post :transfer, :id => @project.permalink, :project => {:user_id => @user.id}
      response.status.should == '401 Unauthorized'
      
      @project.reload.user.should == @owner
    end
  end
  
  describe "#show" do
    it "shows a project" do
      login_as @user
      
      get :show, :id => @project.permalink
      response.should be_success
      JSON.parse(response.body).has_key?('project').should == true
    end
    
    it "should not show a project the user doesn't belong to" do
      @user2 = Factory.create(:confirmed_user)
      login_as @user2
      
      get :show, :id => @project.permalink
      response.status.should == '401 Unauthorized'
    end
  end
  
  describe "#destroy" do
    it "should destroy a project" do
      login_as @owner
      
      Project.count.should == 1
      post :destroy, :id => @project.permalink
      response.should be_success
      Project.count.should == 0
    end
    
    it "should only allow the owner or an admin to destroy a project" do
      login_as @user
      
      Project.count.should == 1
      post :destroy, :id => @project.permalink
      response.status.should == '401 Unauthorized'
      Project.count.should == 1
    end
  end
  
end