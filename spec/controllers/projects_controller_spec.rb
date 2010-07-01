require 'spec_helper'

describe ProjectsController do
  
  describe "#create" do
    it "creates a project with invitations" do
      login_as(:confirmed_user)
    
      @user2 = Factory.create(:user)
    
      project_attributes = Factory.attributes_for(:project, :user => nil,
        :invite_users => [@user2.id],
        :invite_emails => "richard.roe@law.uni"
      )

      lambda {
        post :create, :project => project_attributes
        response.should be_redirect
        p response.headers
      }.should change(Project, :count)
    
      project = Project.last(:order => 'id')
      project.should have(2).invitations
    end
  end
  
end