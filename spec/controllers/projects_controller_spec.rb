require 'spec_helper'

describe ProjectsController do
  
  describe "#create" do
    it "creates a project with invitations" do
      login_as(:confirmed_user)
    
      @user2 = Factory.create(:user)
    
      project_attributes = Factory.attributes_for(:project,
        :invite_users => [@user2.id],
        :invite_emails => "richard.roe@law.uni",
        :organization_id => Factory(:organization).id
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
  
  describe "#join" do
    it "should let admins from the projects organization add themselves" do
      @project = Factory.create(:project)
      @user = Factory.create(:confirmed_user)
      @project.organization.add_member(@user, Membership::ROLES[:admin])
      login_as @user
      
      lambda {
        get :join, :id => @project.permalink
      }.should change(Person, :count)
      
      @project.people(true).map(&:user_id).include?(@project.user_id).should == true
    end
    
    it "should let people add themselves to public projects as commenters" do
      @project = Factory.create(:project)
      @project.update_attribute(:public, true)
      @user = Factory.create(:confirmed_user)
      login_as @user
      
      lambda {
        get :join, :id => @project.permalink
      }.should change(Person, :count)
      
      @project.people(true).map(&:user_id).include?(@user.id).should == true
    end
    
    it "should not allow people to add themselves to non-public projects" do
      @project = Factory.create(:project)
      @user = Factory.create(:confirmed_user)
      
      login_as @user
      
      lambda {
        get :join, :id => @project.permalink
      }.should_not change(Person, :count)
      
      @project.people(true).map(&:user_id).include?(@user.id).should == false
    end
  end
end