require File.dirname(__FILE__) + '/../spec_helper'

describe Task do
  
  it { should belong_to(:project) }
  it { should belong_to(:task_list) }
  it { should belong_to(:page) }
  it { should belong_to(:assigned) }
  it { should have_many(:comments) }

  it { should validate_length_of :name, :within => 1..255 }

  describe "a new task" do
    before { @task = Factory(:task) }

    it "should add the task creator as a watcher" do      
      @task.watchers.should include(@task.user)
    end
    
    it "should be created with a new status" do
      @task.status_name.should == 'new'
    end
    
    it "should be created with no assigned user" do
      @task.assigned.should be_nil
    end
  end
  
  describe "an assigned task" do
    before do
      @user = Factory(:user)
      @task = Factory(:task)
      @assignee = Factory(:user)
    end

    it "should add the assigned user as a watcher" do
      person = @task.project.add_user(@assignee)
      @task.assigned = person
      @task.save.should be_true
      @task.watchers.should include(@assignee)
    end
            
    it "should not allow assigning it to users outside the project" do
      project = Factory(:project)
      @task.assigned = project.people.first
      @task.save.should be_false
      @task.watchers.should_not include(project.users.first)
    end
    
    it "should be marked as open when assigned to somebody"

    it "should send an email to the responsible"
  end

  describe "factories" do
    it "should generate a valid task" do
      task = Factory.create(:task)
      task.valid?.should be_true
    end
  end
  
end
