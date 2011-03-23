require 'spec_helper'

describe Activity do
  describe "target when deleting objects" do
    it "should still be valid when deleting core project objects" do
      
      project = Factory.create(:project)
      Factory.create(:comment, :project => project)
      Factory.create(:conversation, :project => project)
      Factory.create(:task_list, :project => project)
      Factory.create(:upload, :project => project)
      page = Factory.create(:page, :project => project)
      
      note = page.build_note({:name => 'Office Ettiquete'}).tap do |n|
        n.updated_by = project.user
        n.save
      end
      divider = page.build_note({:name => 'Office Ettiquete'}).tap do |n|
        n.updated_by = project.user
        n.save
      end
      
      Activity.count.should_not == 0
      Activity.all.any? { |a| a.target.nil? }.should == false
      
      Person.destroy_all
      Comment.destroy_all
      Conversation.destroy_all
      TaskList.destroy_all
      Page.destroy_all
      
      Activity.all.any? { |a| a.target.nil? }.should == false
    end

    it "should let the activity have its own timestamp" do
      project = Factory :project, :created_at => 4.weeks.ago
      u = Factory :user, :created_at => 4.weeks.ago
      p = Factory :person, :user => u, :project => project, :created_at => 3.weeks.ago
      p.destroy
      activity = Activity.for_projects(project).first
      activity.target.should == p
      activity.action.should == 'delete'
      activity.created_at.should be_within(10.seconds).of(Time.now)
    end
  end

  describe "activities with threaded items" do
    before do
      @user = Factory :user, :login => 'jordi', :first_name => 'Jordi', :last_name => 'Romero', :email => 'jordi@teambox.com'
      @project = Factory :project, :user => @user
      @n = Teambox.config.activities_per_page - 1
    end

    it "should return all the activities on an unordered scenario" do

      # We create a conversation
      c1 = Factory :conversation, :project => @project, :user => @user
      # whatever goes from here -->
        # We put some activities that will be swallowed
        5.times { Factory :page, :user => @user, :project => @project }
        3.times { Factory :conversation, :project => @project, :user => @user }
      # <-- to here will be lost

      # We sleep to prevent the same timestamp on the updated_at field
      sleep 1

      # We comment on the first conversation
      Factory :comment, :project => @project, :user => @user, :target => c1
      sleep 1

      # Now we add 24 activities, so in one page we can only fit these
      # activities plus the last thread. As the thread will be the last activity,
      # we'll fetch the activities with id < that activity's thread
      @n.times { Factory :page, :user => @user, :project => @project }
      Activity.count.should == @n + 15

      all_threads = []

      activities = Activity.for_projects(@project)
      threads = activities.threads.all
      last_activity = threads.last
      all_threads += threads.collect(&:id)

      while threads.any? do
        activities = Activity.for_projects(@project).before(last_activity)
        threads = activities.threads.all
        last_activity = threads.last
        all_threads += threads.collect(&:id)
      end

      # We should render all the threads and simple activities
      all_threads.sort.should == Activity.threads.all.collect(&:id).sort
    end

    it "should create one activity per item created" do
      c1 = Factory :conversation, :project => @project, :user => @user
      3.times { Factory :comment, :project => @project, :user => @user, :target => c1, :body => "I say #{Factory.next :name}" }
      c2 = Factory :conversation, :project => @project, :user => @user
      Factory :comment, :project => @project, :user => @user, :target => c1, :body => "Last comment to mess everything up"
      p = Factory :person, :project => @project
      sc = Factory :simple_conversation, :project => @project, :user => @user
      tl = Factory :task_list, :project => @project, :user => @user
      t = Factory :task, :project => @project, :user => @user

      activities = Activity.for_projects(@project).threads.all

      activities.collect(&:last_id).should be_descendant
      activities.collect(&:id).should_not be_descendant # Because there's activity between two activities in a thread, what makes it jump

      match_activity activities[-1], @project, 'create' # First activity...
      match_activity activities[-2], c2, 'create'
      match_activity activities[-3], c1, 'create'
      match_activity activities[-4], p, 'create'
      match_activity activities[-5], sc, 'create'
      match_activity activities[-6], tl, 'create'
      match_activity activities[-7], t, 'create'
    end

    def match_activity(activity, target, action)
      activity.target.should == target
      activity.action.should == action
    end

  end
end

