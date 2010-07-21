require 'spec_helper'

describe ApiV1::ProjectsController do
  before do
    @user = Factory.create(:confirmed_user)
    @project = Factory.create(:project)
    @project.add_user(@user)
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
  
  describe "#show" do
    it "shows a project" do
      login_as @user
      
      get :show, :id => @project.permalink
      response.should be_success
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
      login_as @project.user
      
      Project.count.should == 1
      post :destroy, :id => @project.permalink
      response.should be_success
      Project.count.should == 0
    end
    
    it "should only allow the owner or an admin to destroy a project" do
      login_as @project.user
      
      Project.count.should == 1
      post :destroy, :id => @project.permalink
      response.should be_success
      Project.count.should == 0
    end
  end
  
end