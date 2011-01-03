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
  
  it "should allow creation with given statuses" do
    Task::STATUS_NAMES.each do |status_name|
      task = Factory(:task, :status => Task::STATUSES[status_name])
      task.valid?.should == true
    end
  end
  
  it "should not allow a user to set an arbitrary status" do
    task = Factory.build(:task, :status => 102203)
    task.valid?.should == false
    task.errors_on(:status).length.should == 1
  end
  
  it "doesn't break when assigning user on create" do
    task_list = Factory(:task_list)
    person = Factory(:person, :project => task_list.project)
    task = Factory.build(:task, :task_list => task_list, :project => nil, :assigned => person)
    lambda { task.save }.should_not raise_error
  end
  
  it "errors out on unknown status name" do
    task = Factory.build(:task)
    lambda {
      task.status_name = 'silly'
    }.should raise_error(ArgumentError)
  end

  describe "assigning tasks" do
    before do
      @user = Factory(:user)
      @task = Factory(:task)
    end
    
    context "valid user" do
      before do
        @task.project.add_user @user
      end
      
      it "should add the assigned user as a watcher" do
        @task.assign_to @user
        @task.should be_assigned_to(@user)
        @task.watchers.should include(@user)
      end
    
      it "transitions from new to open" do
        @task.assign_to @user
        @task.status_name.should == :open
      end
    
      it "doesn't transition from closed to open" do
        @task.status_name = :resolved
        @task.save(:validate => false)
        @task.assign_to @user
        @task.status_name.should == :resolved
      end
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
      @task.errors_on(:assigned).should == ["Assigned user doesn't belong to the project"]
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
      tasks = Task.active.assigned_to(@user).order('name').all
      tasks.map(&:name).should == ["Feed the dog", "Feed the cat"]
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
  
  describe "creating with assigned user and first comment" do
    before do
      @task_list = Factory(:task_list)
      @project = @task_list.project
      @user = @project.user
    end
    
    it "tracks the initial assigned user and status" do
      task = @task_list.tasks.create_by_user(@user,
        :assigned_id => @project.people.first.id, :name => "My task",
        :comments_attributes => [{:body => "My comment"}]
      )
      
      task.should be_assigned
      task.should be_open
      
      comment = task.comments.first
      comment.assigned_id.should == task.assigned_id
      comment.status.should == task.status
    end
  end
  
  describe "updating" do
    it "allows several blank comments with hours" do
      task = Factory(:task, :comments_attributes => {"0" => {:human_hours => "30m"}})
      task.update_attributes(:comments_attributes => {"0" => {:human_hours => "30m"}})
      task.update_attributes(:comments_attributes => {"0" => {:hours => "0.2"}})
      task.should have(3).comments
      task.total_hours.should be_within(0.001).of(1.2)
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
      
      # We use find rather than reload because the #save_changes_to_comment
      # callback set's an ivar to impede reexecution
      task = Task.find(task.id)
      task.updating_user = user

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

    it "saves completed at" do
      task = Factory(:task)
      task.completed_at.should be_nil

      task.update_attributes(:status => "1", :comments_attributes => [{:body => ""}])
      task.reload
      task.completed_at.should be_nil

      task.update_attributes(:status => "4", :comments_attributes => [{:body => ""}])
      task.reload
      task.completed_at.beginning_of_day.to_date.should == Time.now.beginning_of_day.to_date

      task.update_attributes(:status => "2", :comments_attributes => [{:body => ""}])
      task.reload
      task.completed_at.should be_nil

      task.update_attributes(:status => "3", :comments_attributes => [{:body => ""}])
      task.reload
      task.completed_at.beginning_of_day.to_date.should == Time.now.beginning_of_day.to_date
    end

    it "saves assigned user transitions" do
      task = Factory(:task)
      user = Factory(:user)
      user2 = Factory(:user); person2 = Factory(:person, :user => user2, :project => task.project)
      user3 = Factory(:user); person3 = Factory(:person, :user => user3, :project => task.project)
      task.updating_user = user
      task.reload.update_attributes!(:assigned_id => person2.id, :comments_attributes => [{:body => "Do it by tomorrow"}])
      task.should be_assigned_to(user2)
      task.should have(1).comments
      
      comment = task.comments.last
      comment.user.should == user
      comment.body.should == "Do it by tomorrow"
      comment.previous_assigned_id.should be_nil
      comment.assigned_id.should == person2.id
      
      # We use find rather than reload because the #save_changes_to_comment
      # callback set's an ivar to impede reexecution
      task = Task.find(task.id)
      task.updating_user = user

      task.update_attributes(:assigned_id => person3.id, :comments_attributes => [{:body => ""}])
      task.should be_assigned_to(user3)
      task.should have(2).comments
      
      comment = task.comments.last
      comment.user.should == user
      comment.body.should be_blank
      comment.previous_assigned_id.should == person2.id
      comment.assigned_id.should == person3.id
    end

    it "displays assigned users even when they are destroyed" do
      # Require with_deleted relationship port in immortal
      user = Factory(:mislav)
      project = Factory(:project)
      person = Factory(:person, :project => project, :user => user)
      task = Factory(:task, :project => project)
      task.assigned = person
      task.save!
      person.destroy_without_callbacks # We don't use destroy because we want to avoid the nullify from Person#tasks association
      task.reload.assigned.user.name.should == "Mislav Marohnić"
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
