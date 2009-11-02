require File.dirname(__FILE__) + '/../spec_helper'

describe Project do

  describe "creating" do 
    before do
      @owner = Factory.create(:user)
      @project = Factory.create(:project, :user_id => @owner.id)
    end

    it "should belong to its owner" do
      @project.user.should == @owner
      @project.owner?(@owner).should be_true
      @project.users.should include(@owner)
      @owner.reload
      @owner.projects.should include(@project)
    end
    
    it "should add users to the project, only once" do
      user = Factory.create(:user)
      lambda { person = @project.add_user(user) }.should change(@project, :users)
#      lambda { person = @project.add_user(user) }.should_not change(:project, :users)
      person.user.should == user
      person.project.should == @project
    end
  end

end