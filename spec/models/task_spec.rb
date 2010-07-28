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
  
  describe "assigned_to filter" do
    before(:all) do
      @user = Factory(:user)
      
      @projects = [Factory(:project), Factory(:project), Factory(:archived_project)]
      people = @projects.map do |project|
        Factory(:person, :user => @user, :project => project)
      end
      
      Factory(:task, :project => @projects[0])
      Factory(:task, :project => @projects[0], :assigned => people[0], :name => "Feed the cat")
      Factory(:resolved_task, :project => @projects[0], :assigned => people[0])
      Factory(:task, :project => @projects[1], :assigned => people[1], :name => "Feed the dog")
      Factory(:task, :project => @projects[2], :assigned => people[2])
    end
    
    after(:all) do
      User.delete_all
      Project.delete_all
    end
    
    it "gets correct count" do
      Task.active.assigned_to(@user).count.should == 2
    end
    
    it "gets correct tasks" do
      tasks = Task.active.assigned_to(@user).all(:order => 'tasks.id')
      tasks.map(&:name).should == ["Feed the cat", "Feed the dog"]
    end
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

end
