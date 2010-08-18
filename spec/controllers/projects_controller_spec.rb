require 'spec_helper'

describe ProjectsController do
  
  describe "#create" do
    it "creates a project with invitations" do
      login_as(:confirmed_user)
    
      @user2 = Factory.create(:user)
    
      project_attributes = Factory.attributes_for(:project, :user => nil,
        :invite_users => [@user2.id],
        :invite_emails => "richard.roe@law.uni",
        :organization_name => 'TeamCo'
      )

      lambda {
        post :create, :project => project_attributes
        response.should be_redirect
      }.should change(Project, :count)
    
      project = Project.last(:order => 'id')
      project.should have(2).invitations
    end
  end
  
  describe "#create" do
    it "creates a project with an existing organization" do
      @user = Factory.create(:confirmed_user)
      login_as @user
    
      @user2 = Factory.create(:user)
      @org = Factory.create(:organization)
      @org.add_member(@user, Membership::ROLES[:admin])
    
      project_attributes = Factory.attributes_for(:project,
        :invite_users => [@user2.id],
        :invite_emails => "richard.roe@law.uni",
        :organization_id => @org.id
      )

      lambda {
        post :create, :project => project_attributes
        response.should be_redirect
      }.should change(Project, :count)
    
      project = Project.last(:order => 'id')
      project.should have(2).invitations
    end
  end
  
end