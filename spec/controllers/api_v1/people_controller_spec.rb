require 'spec_helper'

describe ApiV1::PeopleController do
  before do
    make_a_typical_project
  end

  describe "#index" do
    it "shows people in the project" do
      login_as @admin

      get :index, :project_id => @project.permalink
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      data['objects'].length.should == 4

      @project.user_ids.each{ |uid| references.include?("#{uid}_User").should == true }
    end

    it "shows people in the project referenced by id" do
      login_as @admin

      get :index, :project_id => @project.id
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 4
    end

    it "limits memberships" do
      login_as @user

      get :index, :project_id => @project.permalink, :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 1
    end

    it "limit can be overridden" do
      login_as @user

      10.times { Factory.create(:person, :project => @project) }

      get :index, :project_id => @project.permalink, :count => 0
      response.should be_success
      JSON.parse(response.body)['objects'].length.should == 14

      get :index, :project_id => @project.permalink, :count => 20
      response.should be_success
      JSON.parse(response.body)['objects'].length.should == 14
    end

    it "limits and offsets people" do
      login_as @user

      get :index, :project_id => @project.permalink, :since_id => @project.people[-2].id, :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.should == [@project.people.last.id]
    end
  end

  describe "#show" do
    it "shows a person with references" do
      login_as @admin

      get :show, :project_id => @project.permalink, :id => @project.people.first.id
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      data['id'].to_i.should == @project.people.first.id

      references.include?("#{@project.people.first.user_id}_User").should == true
    end
  end

  describe "#update" do
    it "should allow an admin to modify a person" do
      login_as @admin

      put :update, :project_id => @project.permalink, :id => @user.person_for(@project).id, :role => Person::ROLES[:admin]
      response.should be_success

      @project.reload.admin?(@user).should == true
    end

    it "should not allow a non-admin to modify a person" do
      login_as @user

      put :update, :project_id => @project.permalink, :id => @observer.person_for(@project).id, :role => Person::ROLES[:admin]
      response.status.should == 401

      @project.reload.admin?(@user).should == false
    end
    
    it "should ensure the last admin isn't updated out of the project" do
      @project.people.each{|p|p.destroy}
      @project.people(true).length.should == 1
      login_as @project.people.last.user

      put :update, :project_id => @project.permalink, :id => @project.people.first.id, :role => Person::ROLES[:observer]
      response.status.should == 401
      
      @project.people(true).length.should == 1
    end
  end

  describe "#destroy" do
    it "should allow an admin to destroy a person" do
      login_as @admin

      put :destroy, :project_id => @project.permalink, :id => @user.person_for(@project).id
      response.should be_success

      @project.people(true).length.should == 3
    end

    it "should allow a user to remove themselves from the project" do
      login_as @admin

      put :destroy, :project_id => @project.permalink, :id => @admin.person_for(@project).id
      response.should be_success

      @project.people(true).length.should == 3
    end

    it "should not allow a non-admin to destroy another person" do
      login_as @user

      put :destroy, :project_id => @project.permalink, :id => @observer.person_for(@project).id
      response.status.should == 401

      @project.people(true).length.should == 4
    end
    
    it "should not destroy the last person in a project" do
      @project.people.each{|p|p.destroy}
      @project.people(true).length.should == 1
      login_as @project.people.last.user

      put :destroy, :project_id => @project.permalink, :id => @project.people.first.id
      response.status.should == 401
      
      @project.people(true).length.should == 1
    end
  end
end
