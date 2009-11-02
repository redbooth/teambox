require File.dirname(__FILE__) + '/../spec_helper'

describe Project do

  it { should belong_to(:user)}
  it { should have_many(:people) }
  it { should have_many(:users) }

  it { should have_many(:task_lists) }
  it { should have_many(:tasks) }
  it { should have_many(:invitations) }
  it { should have_many(:conversations) }
  it { should have_many(:pages) }
  it { should have_many(:comments) }
  it { should have_many(:uploads) }
  it { should have_many(:activities) }

  it { should validate_presence_of    :user }
  # it { should validate_associated     :people }
  it { should validate_length_of      :name, :minimum => 3 }
  it { should validate_length_of      :permalink, :minimum => 5 }

  describe "creating" do 
    before do
      @owner = Factory.create(:user)
      @project = Factory.create(:project, :user_id => @owner.id)
    end

    it "should belong to its owner" do
      @project.user.should == @owner
      @project.owner?(@owner).should be_true
      @project.users.should == [@owner]
      @owner.reload.projects.should include(@project)
    end
    
    it "should add users to the project, only once" do
      user = Factory.create(:user)
      person = @project.add_user(user)
      person.user.should == user
      person.project.should == @project
      @project.should have(2).users
      lambda { @project.add_user(user) }.should_not change(@project, :users)
      Activity.last.project.should == @project
      Activity.last.comment_type.should == nil
      Activity.last.target.should == person
      Activity.last.action.should == 'create'
      Activity.last.user.should == user
    end
    
    it "should log when a user is added to a project" do
      user = Factory.create(:user)
    end
    
    it "should remove users" do
      user = Factory.create(:user)
      person = @project.add_user(user)
      @project.should have(2).users
      @project.reload.remove_user(user)
      @project.should have(1).users
      @project.users.should_not include(user)
      user.reload.projects.should_not include(@project)
#      Activity.last.project.should == @project
#      Activity.last.comment_type.should == nil
#      Activity.last.target.should == person
#      Activity.last.action.should == 'delete'
#      Activity.last.user.should == user
    end
    
    it "make sure activities still work when the object is deleted"
  end
  
  describe "permalinks" do
    it "should use the given permalink if not taken" do
      project1 = Factory.create(:project, {:name => 'Alice Lidell', :permalink => 'mad-hatter'})
      project1.permalink.should == 'mad-hatter'
      project2 = Factory.create(:project, {:name => 'Lorina Lidell', :permalink => 'mad-hatter'})
      project2.permalink.should == 'mad-hatter-2'
    end
    
    it "should generate a unique permalink if none is given" do
      project1 = Factory.create(:project, :name => 'Cheshire   Cat!!')
      project1.permalink.should == 'cheshire-cat'
      project2 = Factory.create(:project, :name => 'Cheshire Cat')
      project2.permalink.should == 'cheshire-cat-2'
    end
  end
end
