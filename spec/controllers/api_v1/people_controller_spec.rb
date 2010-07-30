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
      
      JSON.parse(response.body).length.should == 4
    end
  end
  
  describe "#show" do
    it "shows a person" do
      login_as @admin
      
      get :show, :project_id => @project.permalink, :id => @project.people.first.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @project.people.first.id
    end
  end
  
  describe "#update" do
    it "should allow an admin to modify a person" do
      login_as @admin
      
      put :update, :project_id => @project.permalink, :id => @user.person_for(@project).id, :person => {:role => Person::ROLES[:admin]}
      response.should be_success
      
      @project.reload.admin?(@user).should == true
    end
    
    it "should not allow the owner to be modified" do
      login_as @admin
      
      put :update, :project_id => @project.permalink, :id => @owner.person_for(@project).id, :person => {:role => Person::ROLES[:participant]}
      response.status.should == '422 Unprocessable Entity'
      
      @project.reload.admin?(@owner).should == true
    end
    
    it "should not allow a non-admin to modify a person" do
      login_as @user
      
      put :update, :project_id => @project.permalink, :id => @observer.person_for(@project).id, :person => {:role => Person::ROLES[:admin]}
      response.status.should == '401 Unauthorized'
      
      @project.reload.admin?(@user).should == false
    end
  end
  
  describe "#destroy" do
    it "should allow an admin to destroy a person" do
      login_as @admin
      
      put :destroy, :project_id => @project.permalink, :id => @user.person_for(@project).id
      response.should be_success
      
      @project.people(true).length.should == 3
    end
    
    it "should not allow an owner to remove themselves from the project" do
      login_as @owner
      
      put :destroy, :project_id => @project.permalink, :id => @owner.person_for(@project).id
      response.status.should == '401 Unauthorized'
      
      @project.people(true).length.should == 4
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
      response.status.should == '401 Unauthorized'
      
      @project.people(true).length.should == 4
    end
  end
end