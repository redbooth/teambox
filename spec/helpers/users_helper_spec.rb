require 'spec_helper'

describe UsersHelper do
  before do
    @user = Factory(:confirmed_user)
    @project = Factory(:project, :user => @user)
    login_as @user
  end

  describe "json_projects" do
    before do
      @projects = JSON.parse(json_projects)
    end
    it "should return an hash of projects with the user's role" do
      project = @projects[@project.id.to_s]
      project['name'].should == @project.name
      project['permalink'].should == @project.permalink
      project['role'].should == Person::ROLES[:admin].to_s
    end
  end

  describe "json_organizations" do
    it "shouldn't include deleted organizations" do
      o1 = Factory :organization
      o2 = Factory :organization
      o1.add_member @user
      o2.add_member @user
      o2.projects.destroy_all
      o2.destroy.should be_true
      organizations = JSON.parse(json_organizations)
      organizations.collect {|o| o['permalink']}.should == [@project.organization.permalink, o1.permalink]
    end
  end

  describe "json_external_organizations" do
    it "shouldn't include deleted organizations" do
      p1 = Factory :project
      o1 = p1.organization
      p2 = Factory :project
      o2 = p2.organization
      p1.add_user @user
      p2.add_user @user
      o2.projects.destroy_all
      o2.destroy.should be_true
      organizations = JSON.parse(json_external_organizations)
      organizations.collect {|o| o['permalink']}.should == [@project.organization.permalink, o1.permalink]
    end
  end
end

