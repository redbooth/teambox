require 'spec_helper'

describe ApiV1::ProjectsController do
  before do
    make_a_typical_project

    @other_project = Factory.create(:project, :user => @user)
  end

  describe "#index" do
    it "shows projects the user belongs to" do
      login_as @user

      get :index
      response.should be_success
      list = JSON.parse(response.body)
      list['type'].should == 'List'
      list['objects'].each {|o| o['type'].should == 'Project'}
      list['objects'].length.should == 2

      references = list['references'].map{|r| "#{r['id']}_#{r['type']}"}
      references.include?("#{@project.organization.id}_Organization").should == true
      references.include?("#{@other_project.organization.id}_Organization").should == true
      references.include?("#{@project.user_id}_User").should == true
      references.include?("#{@other_project.user_id}_User").should == true
    end

    it "shows projects with a JSONP callback" do
      login_as @user

      get :index, :callback => 'lolCat', :format => 'js'
      response.should be_success

      response.body.split('(')[0].should == 'lolCat'
    end

    it "shows projects as JSON when requested with the :text format" do
      login_as @user

      get :index, :format => 'text'
      response.should be_success
      response.headers['Content-Type'][/text\/plain/].should_not be_nil
      list = JSON.parse(response.body)
      list['type'].should == 'List'
      list['objects'].each {|o| o['type'].should == 'Project'}
      list['objects'].length.should == 2
    end

    it "does not show projects the user doesn't belong to" do
      login_as Factory(:confirmed_user)

      get :index
      response.should be_success
      JSON.parse(response.body)['objects'].length.should == 0
    end

    it "limits projects" do
      login_as @user

      get :index, :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 1
    end

    it "limits and offsets projects" do
      login_as @user

      get :index, :since_id => @user.projects.first.id, :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.should == [@user.projects.last.id]
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

  describe "#show" do
    it "shows a project with references" do
      login_as @user

      get :show, :id => @project.permalink
      response.should be_success

      data = JSON.parse(response.body)
      data['type'].should == 'Project'
      data['id'].to_i.should == @project.id
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}

      references.include?("#{@project.organization.id}_Organization").should == true
      references.include?("#{@project.user_id}_User").should == true
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
      response.status.should == 403

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

      Project.count.should == 2
      put :destroy, :id => @project.permalink
      response.should be_success
      Project.count.should == 1
    end

    it "should only allow admins to destroy a project" do
      login_as @observer

      Project.count.should == 2
      put :destroy, :id => @project.permalink
      response.status.should == 401
      Project.count.should == 2
    end
  end

end
