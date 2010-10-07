require 'spec_helper'

describe OrganizationsController do
  
  describe "#create" do
    it "creates an organization with the current user as an admin" do
      @user = Factory.create(:confirmed_user)
      login_as @user
    
      organization_attributes = Factory.attributes_for(:organization)

      lambda {
        post :create, :organization => organization_attributes
        response.should be_redirect
      }.should change(Organization, :count)
    
      organization = Organization.last(:order => 'id')
      organization.should have(1).memberships
      organization.memberships.first.role.should == Membership::ROLES[:admin]
      organization.memberships.first.user.should == @user
    end
  end
end