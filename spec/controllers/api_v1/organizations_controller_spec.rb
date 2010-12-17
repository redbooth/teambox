require 'spec_helper'

describe ApiV1::OrganizationsController do
  before do
    make_a_typical_project
  end
  
  describe "#index" do
    it "shows organizations the user belongs to" do
      login_as @user
      
      get :index
      response.should be_success
      JSON.parse(response.body)['objects'].length.should == 1
    end
    
    it "does not show organizations the user doesn't belong to" do
      login_as Factory(:confirmed_user)
      
      get :index
      response.should be_success
      JSON.parse(response.body)['objects'].length.should == 0
    end
    
    it "returns references for linked objects" do
      login_as @user
      
      get :index
      response.should be_success
      
      data = JSON.parse(response.body)
      data['references'].should_not == nil
    end
  end
  
  describe "#create" do
    it "creates an organization" do
      login_as @user
      
      organization_attributes = Factory.attributes_for(:organization)

      lambda {
        post :create, organization_attributes
        response.status.should == 201
      }.should change(Organization, :count)
      
      JSON.parse(response.body)['name'].should == organization_attributes[:name]
      Organization.last.memberships.first.user.should == @user
    end
  end
  
  describe "#update" do
    it "should allow an admin to update the organization" do
      login_as @admin
      
      put :update, :id => @organization.permalink, :permalink => 'ffffuuuuuu'
      response.should be_success
      
      @organization.reload.permalink.should == 'ffffuuuuuu'
    end
    
    it "should not allow a non-admin to update the organization" do
      login_as @user
      
      put :update, :id => @organization.permalink, :permalink => 'ffffuuuuuu'
      response.status.should == 401
      
      @organization.reload.permalink.should_not == 'ffffuuuuuu'
    end
  end
  
  describe "#show" do
    it "shows an organization" do
      login_as @user
      
      get :show, :id => @organization.permalink
      response.should be_success
      JSON.parse(response.body)['id'].to_i.should == @organization.id
    end
    
    it "shows an organization by id" do
      login_as @user
      
      get :show, :id => @organization.id
      response.should be_success
      JSON.parse(response.body)['id'].to_i.should == @organization.id
    end
    
    it "should not show an organization the user doesn't belong to" do
      @user2 = Factory.create(:confirmed_user)
      login_as @user2
      
      get :show, :id => @organization.permalink
      response.status.should == 404
    end
  end
end
