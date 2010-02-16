require File.dirname(__FILE__) + '/../spec_helper'

describe Task do

  it { should belong_to(:project) }
  it { should belong_to(:task_list) }
  it { should belong_to(:page) }
  it { should belong_to(:assigned) }
  it { should have_many(:comments) }

  it { should validate_length_of(:name, :within => 1..255) }

  describe "a new task" do
    before { @task = Factory(:task); @task.project.add_user(@task.user) }
    
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

  describe "when assigning a task to a user" do
    it "the person belonging to the user should be assigned" do
      user = Factory(:user)
      project = Factory(:project)
      task = Factory(:task, :project => project)
      project.add_user(user)
      task.assign_to(user)
      task.should be_assigned_to(user)
    end
  end

  describe "factories" do
    it "should generate a valid task" do
      task = Factory.create(:task)
      task.valid?.should be_true
    end
  end

  describe "when fetching through the due_today scope" do
    before do
      @for_today = Factory(:task, :due_on => Date.today)
      @for_tomorrow = Factory(:task, :due_on => Date.today + 1)
    end
    it "should return tasks that are due today" do
      Task.due_today.should include(@for_today)
      Task.due_today.should_not include(@for_tomorrow)
    end
  end

  describe "when archived" do
    before do
      @task = Factory(:archived_task)
    end
    describe "and reopened" do
      before do
        @task.reopen
      end
      it "should be unarchived" do
        @task.should_not be_archived
      end
    end
  end

  describe "when reopened" do
    before do
      @task = Factory(:task)
      @task.reopen
    end
    it "should be open" do
      @task.should be_open
    end
  end

end
