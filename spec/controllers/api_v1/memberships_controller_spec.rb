require 'spec_helper'

describe ApiV1::MembershipsController do
  before do
    make_a_typical_project

    @other_user = Factory.create(:user)
    @organization.add_member(@other_user)
  end

  describe "#index" do
    it "shows members in the organization" do
      login_as @admin

      get :index, :organization_id => @organization.permalink
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}

      data['objects'].length.should == @organization.memberships.length
      references.include?("#{@organization.id}_Organization").should == true
      @organization.memberships.each do |m|
        references.include?("#{m.user_id}_User").should == true
      end
    end

    it "shows members in the organization referenced by id" do
      login_as @admin

      get :index, :organization_id => @organization.id
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == @organization.memberships.length
    end

    it "returns references for linked objects" do
      login_as @admin

      get :index, :organization_id => @organization.permalink
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      activities = data['objects']

      references.include?("#{@organization.id}_Organization").should == true
      references.include?("#{@organization.memberships.first.user_id}_User").should == true
    end

    it "limits memberships" do
      login_as @user

      get :index, :organization_id => @organization.permalink, :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 1
    end

    it "limits and offsets memberships" do
      login_as @user

      get :index, :organization_id => @organization.permalink, :since_id => @organization.memberships.first.id, :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.should == [@organization.memberships.last.id]
    end
  end

  describe "#show" do
    it "shows a member with references" do
      login_as @admin

      get :show, :organization_id => @organization.permalink, :id => @organization.memberships.first.id
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      data['id'].to_i.should == @organization.memberships.first.id

      references.include?("#{@organization.id}_Organization").should == true
      references.include?("#{@organization.memberships.first.user_id}_User").should == true
    end
  end

  describe "#update" do
    it "should allow an admin to modify a member" do
      login_as @admin

      put :update, :organization_id => @organization.permalink, :id => @user.member_for(@organization).id, :role => Membership::ROLES[:admin]
      response.should be_success

      @organization.reload.is_admin?(@user).should == true
    end

    it "should not allow a non-admin to modify a member" do
      login_as @user

      put :update, :organization_id => @organization.permalink, :id => @observer.member_for(@organization).id, :role => Membership::ROLES[:admin]
      response.status.should == 401

      @organization.reload.is_admin?(@user).should == false
    end
  end

  describe "#destroy" do
    it "should allow an admin to destroy a member" do
      login_as @admin

      lambda {
        put :destroy, :organization_id => @organization.permalink, :id => @user.member_for(@organization).id
        response.should be_success
      }.should change(Membership, :count)
    end

    it "should not allow to delete the last admin" do
      @organization.memberships.where(['user_id != ?', @admin]).destroy_all
      login_as @admin

      lambda {
        put :destroy, :organization_id => @organization.permalink, :id => @admin.member_for(@organization).id
        response.status.should == 422
      }.should_not change(Membership, :count)
    end

    it "should allow a user to remove themselves from the organization" do
      login_as @admin

      lambda {
        put :destroy, :organization_id => @organization.permalink, :id => @admin.member_for(@organization).id
        response.should be_success
      }.should change(Membership, :count)
    end

    it "should not allow a non-admin to destroy another member" do
      login_as @user

      lambda {
        put :destroy, :organization_id => @organization.permalink, :id => @observer.member_for(@organization).id
        response.status.should == 401
      }.should_not change(Membership, :count)
    end
  end
end
