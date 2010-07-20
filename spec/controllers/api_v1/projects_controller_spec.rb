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
        response.status.should == 201
      }.should change(Project, :count)
    
      project = Project.last(:order => 'id')
      project.should have(2).invitations
    end
  end
  
  describe "#show" do
    it "shows a project" do
      login_as @user
    
      @user2 = Factory.create(:user)
      
      get :show, :id => @project.permalink
      response.should be_success
    end
    
    it "should not show a project the user doesn't belong to" do
      login_as @user
    
      @project2 = Factory.create(:project)
      
      get :show, :id => @project2.permalink
      response.status.should == 401
    end
  end
  
  describe "#destroy" do
    it "should destroy a project" do
      Project.count.should == 1
      post :destroy, :id => @project.permalink
      response.should be_success
      Project.count.should == 0
    end
  end
  
end