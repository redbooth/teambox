require 'spec_helper'

describe UsersHelper do
  before do
    @user = Factory(:confirmed_user)
    @project = Factory(:project, :user => @user)
  end

  describe "json_projects" do
    before do
      login_as @user
      @projects = JSON.parse(json_projects)
    end
    it "should return an hash of projects with the user's role" do
      project = @projects[@project.id.to_s]
      project['name'].should == @project.name
      project['permalink'].should == @project.permalink
      project['role'].should == Person::ROLES[:admin].to_s
    end
  end
end

