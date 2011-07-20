require 'spec_helper'

describe ApiV1::ProjectsController do
  before do
    make_a_typical_project
  end
  
  describe "#index" do
    it "shows projects the user belongs to" do
      login_as @user
      
      get :index
      response.should be_success
      JSON.parse(response.body)['objects'].length.should == 1
    end
    
    it "shows projects with a JSONP callback" do
      login_as @user
      
      get :index, :callback => 'lolCat', :format => 'js'
      response.should be_success
      
      response.body.split('(')[0].should == 'lolCat'
    end
    
    it "does not show projects the user doesn't belong to" do
      login_as Factory(:confirmed_user)
      
      get :index
      response.should be_success
      JSON.parse(response.body)['objects'].length.should == 0
    end
  end
  
  describe "#create" do
    it "creates a project" do
      login_as @user

      @org = Factory.create(:organization)

      project_attributes = Factory.attributes_for(:project,
        :organization_id => @org.id
      )

      lambda {
        post :create, project_attributes
        response.status.should == 201
      }.should change(Project, :count)

      JSON.parse(response.body)['organization_id'].to_i.should == @org.id
    end
  end
  
  describe "#update" do
    it "should allow an admin to update the project" do
      login_as @admin
      
      put :update, :id => @project.permalink, :permalink => 'ffffuuuuuu'
      response.should be_success
      
      @project.reload.permalink.should == 'ffffuuuuuu'
    end
    
    it "should not allow a non-admin to update the project" do
      login_as @user
      
      put :update, :id => @project.permalink, :permalink => 'ffffuuuuuu'
      response.status.should == 401
      
      @project.reload.permalink.should_not == 'ffffuuuuuu'
    end
  end
  
  describe "#transfer" do
    it "should allow the owner to transfer the project" do
      login_as @owner
      
      put :transfer, :id => @project.permalink, :user_id => @user.id
      response.should be_success
      
      @project.reload.user.should == @user
    end
    
    it "should not allow non-owners to transfer the project" do
      login_as @user
      
      put :transfer, :id => @project.permalink, :user_id => @user.id
      response.status.should == 401
      
      @project.reload.user.should == @owner
    end
  end
  
  describe "#show" do
    it "shows a project" do
      login_as @user
      
      get :show, :id => @project.permalink
      response.should be_success
      JSON.parse(response.body)['id'].to_i.should == @project.id
    end
    
    it "shows a project by id" do
      login_as @user
      
      get :show, :id => @project.id
      response.should be_success
      JSON.parse(response.body)['id'].to_i.should == @project.id
    end
    
    it "should not show a project the user doesn't belong to" do
      @user2 = Factory.create(:confirmed_user)
      login_as @user2
      
      get :show, :id => @project.permalink
      response.status.should == 401
      
      JSON.parse(response.body)['errors']['type'].should == 'InsufficientPermissions'
    end
    
    it "should not show a project which does not exist" do
      login_as @user
      
      get :show, :id => 'omgffffuuuuu'
      
      response.status.should == 404
      
      JSON.parse(response.body)['errors']['type'].should == 'ObjectNotFound'
    end
  end
  
  describe "#destroy" do
    it "should destroy a project" do
      login_as @owner
      
      Project.count.should == 1
      put :destroy, :id => @project.permalink
      response.should be_success
      Project.count.should == 0
    end
    
    it "should only allow the owner to destroy a project" do
      login_as @admin
      
      Project.count.should == 1
      put :destroy, :id => @project.permalink
      response.status.should == 401
      Project.count.should == 1
    end
  end
  
end
