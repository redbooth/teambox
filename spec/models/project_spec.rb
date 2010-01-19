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

  describe "creating a project" do 
    before do
      @owner = Factory.create(:user)
      @project = Factory.create(:project, :user_id => @owner.id)
    end
    
    it "should belong to its owner" do
      @project.user.should == @owner
      @project.owner?(@owner).should be_true
      @project.users.should include(@owner)
      @project.people.first.role.should == Person::ROLES[:admin]
      @owner.reload
      @owner.projects.should include(@project)
    end
  end
    
  describe "inviting users" do 
    before do
      @owner = Factory.create(:user)
      @project = Factory.create(:project, :user_id => @owner.id)
      @user = Factory.create(:user)
    end

    it "should add users only once" do
      person = @project.add_user(@user)
      person.user.should == @user
      person.project.should == @project
      @project.should have(2).users
      lambda { @project.add_user(@user) }.should_not change(@project, :users)
    end
    
    it "should log when a user is added without being invited" do
      person = @project.add_user(@user)
      Activity.last.project.should == @project
      Activity.last.comment_type.should == nil
      Activity.last.target.should == person
      Activity.last.action.should == 'create'
      Activity.last.user.should == @user
      person.reload.source_user.should be_nil
    end
    
    it "should log when a user is added being invited" do
      person = @project.add_user(@user,@owner)
      Activity.last.project.should == @project
      Activity.last.comment_type.should == nil
      Activity.last.target.should == person
      Activity.last.action.should == 'create'
      Activity.last.user.should == @owner
      person.reload.source_user.should == @owner      
    end
  end

  describe "removing users" do 
    before do
      @owner = Factory.create(:user)
      @project = Factory.create(:project, :user_id => @owner.id)
      @user = Factory.create(:user)
      @person = @project.add_user(@user)
    end
  
    it "should remove users" do
      @project.should have(2).users
      @project.reload.remove_user(@user)
      @project.should have(1).users
      @project.users.should_not include(@user)
      @user.reload.projects.should_not include(@project)
    end
    
    it "should log he's leaving the project" do
      @project.reload.remove_user(@user)
      Activity.last.project.should == @project
      Activity.last.comment_type.should == nil
      Activity.last.target.should == @person
      Activity.last.action.should == 'delete'
      Activity.last.user.should == @user      
    end
    
    it "should remove the project from their recent projects" do
      @user.add_recent_project(@project)
      @user.recent_projects.should include(@project)
      @project.reload.remove_user(@user)
      @user.reload.recent_projects.should_not include(@project)
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
  
  describe "deleting projects" do
    before do
      @project = Factory(:project)
      %w(comment conversation task_list page).each do |model|
        Factory(model, :project => @project, :user => @project.user)
      end
      @project.reload.comments.reload
    end
    
    it "should have some elements" do
      Project.count.should == 1
      Comment.count.should == 1
      Conversation.count.should == 1
      TaskList.count.should == 1
      Page.count.should == 1
      Person.count.should == 1
    end
    
    it "destroy all its comments, conversations, task lists, pages, uploads and people" do
      @project.destroy
      Project.count.should == 0
      Comment.count.should == 0
      Conversation.count.should == 0
      TaskList.count.should == 0
      Page.count.should == 0
      Person.count.should == 0
    end
    
  end

  describe "factories" do
    it "should generate Ruby Rockstars project with Mislav in it" do
      project = Factory.create(:ruby_rockstars)
      project.valid?.should be_true
      project.users.first.should == User.find_by_login('mislav')
    end
  end
end