require 'spec_helper'

describe Task do

  it { should belong_to(:project) }
  it { should belong_to(:task_list) }
  it { should belong_to(:page) }
  it { should belong_to(:assigned) }
  it { should have_many(:comments) }

  it { should validate_length_of(:name, :within => 1..255) }

  describe "a new task" do
    before do
      @task = Factory(:task)
      @task.project.add_user(@task.user)
    end
    
    it "should add the task creator as a watcher" do
      @task.watchers.should include(@task.user)
    end

    it "should be created with a new status" do
      @task.status_name.should == :new
    end

    it "should be created with no assigned user" do
      @task.assigned.should be_nil
    end
  end

  describe "assigning tasks" do
    before do
      @user = Factory(:user)
      @task = Factory(:task)
    end

    it "should add the assigned user as a watcher" do
      @task.project.add_user @user
      @task.assign_to @user
      @task.should be_assigned_to(@user)
      @task.watchers.should include(@user)
    end

    it "should not allow assigning it to users outside the project" do
      @task.assign_to @user
      @task.should_not be_assigned_to(@user)
      @task.watchers.should_not include(@user)
    end

    it "validates manually assigned person" do
      project = Factory(:project)
      person = Factory(:person, :user => @user, :project => project)
      
      @task.assigned = person
      @task.should_not be_valid
      @task.errors.on(:assigned).should == "Assigned user doesn't belong to the project"
    end
  end
  
  describe "assigned_to filter" do
    before do
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
    
    it "gets correct count" do
      Task.active.assigned_to(@user).count.should == 2
    end
    
    it "gets correct tasks" do
      tasks = Task.active.assigned_to(@user).all(:order => 'tasks.id')
      tasks.map(&:name).should == ["Feed the cat", "Feed the dog"]
    end
  end
  
  describe "creating with comment" do
    it "ignores comments without body and hours" do
      task = Factory(:task, :comments_attributes => {"0" => {:body => "", :human_hours => ""}})
      task.comments.should be_empty
    end
    
    it "saves nested comment with body" do
      task = Factory(:task, :comments_attributes => {"0" => {:body => "I like robots and I cannot lie"}})
      task.should have(1).comments
    end
    
    it "saves nested comment with hours" do
      task = Factory(:task, :comments_attributes => {"0" => {:human_hours => "42m"}})
      task.should have(1).comments
    end
  end
  
  describe "updating" do
    it "allows several blank comments with hours" do
      task = Factory(:task, :comments_attributes => {"0" => {:human_hours => "30m"}})
      task.update_attributes(:comments_attributes => {"0" => {:human_hours => "30m"}})
      task.update_attributes(:comments_attributes => {"0" => {:hours => "0.2"}})
      task.should have(3).comments
      task.total_hours.should be_close(1.2, 0.001)
    end
    
    it "saves status transitions" do
      task = Factory(:task)
      user = Factory(:user)
      task.updating_user = user
      task.update_attributes(:status => "1", :comments_attributes => [{:body => "Open Sesame"}])
      task.should be_open
      task.should have(1).comments
      
      comment = task.comments.last
      comment.user.should == user
      comment.body.should == "Open Sesame"
      comment.previous_status.should == 0
      comment.status.should == 1
      comment.assigned_id.should be_nil
      
      task.reload
      task.update_attributes(:status => "2", :comments_attributes => [{:body => ""}])
      task.status_name.should == :hold
      task.should have(2).comments
      
      comment = task.comments.last
      comment.user.should == user
      comment.body.should be_blank
      comment.previous_status.should == 1
      comment.status.should == 2
      comment.assigned_id.should be_nil
    end
    
    it "saves assigned user transitions" do
      task = Factory(:task)
      user = Factory(:user)
      user2 = Factory(:user); person2 = Factory(:person, :user => user2, :project => task.project)
      user3 = Factory(:user); person3 = Factory(:person, :user => user3, :project => task.project)
      task.updating_user = user
      task.update_attributes(:assigned_id => person2.id, :comments_attributes => [{:body => "Do it by tomorrow"}])
      task.should be_assigned_to(user2)
      task.should have(1).comments
      
      comment = task.comments.last
      comment.user.should == user
      comment.body.should == "Do it by tomorrow"
      comment.previous_assigned_id.should be_nil
      comment.assigned_id.should == person2.id
      comment.status.should be_nil
      
      task.reload
      task.update_attributes(:assigned_id => person3.id, :comments_attributes => [{:body => ""}])
      task.should be_assigned_to(user3)
      task.should have(2).comments
      
      comment = task.comments.last
      comment.user.should == user
      comment.body.should be_blank
      comment.previous_assigned_id.should == person2.id
      comment.assigned_id.should == person3.id
      comment.status.should be_nil
    end
  end

  describe "due_today scope" do
    before do
      @for_today = Factory(:task, :due_on => Date.today)
      @for_tomorrow = Factory(:task, :due_on => Date.today + 1)
    end
    
    it "should return tasks that are due today" do
      Task.due_today.should include(@for_today)
    end
    
    it "should not return tasks due tomorrow" do
      Task.due_today.should_not include(@for_tomorrow)
    end
  end

end
