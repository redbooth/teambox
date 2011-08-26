require 'spec_helper'
require 'faker'
I18n.reload!

describe ApiV2::ThreadsController do
  before do
    @project = Factory :project
    @user = @project.users.first
    @organization = @project.organization
  end

  describe "#index" do
    describe "unauthenticated" do
      it "shouldn't return activities if not logged in" do
        get :index
        response.should_not be_success
        response.status.should == 401
      end
    end

    describe "authenticated" do
      before do
        login_as @user
      end

      it "should return all the activities in the user's projects" do
        project2 = Factory :project
        project2.add_user @user

        get :index

        response.should be_success
        data = JSON.parse(response.body)

        actual_values = data.collect { |a| "#{a['target_type']}_#{a['target_id']}" }.sort
        expected_values = Activity.for_projects(@user.projects).threads.collect { |a| "#{a.target_type}_#{a.target_id}" }.sort
        actual_values.should == expected_values
      end

      it "should return all the activities for a given project" do
        project2 = Factory :project
        project2.add_user @user
        get :index, :project_id => @project.id

        response.should be_success
        data = JSON.parse(response.body)

        actual_values = data.collect { |a| "#{a['target_type']}_#{a['target_id']}" }.sort
        expected_values = Activity.for_projects(@project).threads.collect { |a| "#{a.target_type}_#{a.target_id}" }.sort
        actual_values.should == expected_values
      end

      it "should only return threaded activities" do
        conversation = Factory :conversation, :project => @project, :user => @user
        task = Factory :task, :project => @project, :user => @user
        Factory :comment, :target => task, :project => @project, :user => @user, :body => Faker::Lorem.sentence
        Factory :comment, :target => conversation, :project => @project, :user => @user, :body => Faker::Lorem.sentence

        get :index

        response.should be_success
        data = JSON.parse(response.body)
        actual_values = data.collect { |a| a['target_type'] }
        expected_values = %w(Conversation Task Project)
        actual_values.should == expected_values
      end

      it "should return nested information for a conversation" do
        conversation = Factory :conversation, :project => @project, :user => @user

        get :index

        response.should be_success
        data = JSON.parse(response.body)
        activity = data.first
        conversation.reload
        conv_activity = Activity.where(:target_type => 'Conversation').where(:target_id => conversation.id).first

        activity['id'].should == conv_activity.id
        activity['target_type'].should == 'Conversation'
        activity['target_id'].should == conversation.id
        activity['user']['username'].should == conv_activity.user.login
        activity['project']['permalink'].should == conv_activity.project.permalink
        activity['target']['name'].should == conversation.name
        activity['target']['type'].should == 'Conversation'
        activity['target']['is_private'].should == conversation.is_private
        activity['target']['comments_count'].should == conversation.comments_count
        activity['target']['simple'].should == conversation.simple
        activity['target']['watchers'].should == Array.wrap(conversation.watcher_ids)
        activity['target']['first_comment']['id'].should == conversation.first_comment.id
        activity['target']['first_comment']['body'].should == conversation.first_comment.body
        activity['target']['first_comment']['user']['username'].should == conversation.first_comment.user.login
        activity['target']['recent_comments'].size.should == 1
        activity['target']['recent_comments'].first['id'].should == conversation.recent_comments.first.id
        # TODO check uploads, gdocs
      end

      it "should return nested information for a task" do
        task = Factory :task, :project => @project, :user => @user, :assigned => @project.people.first, :due_on => 3.days.ago, :comments_attributes => [{:body => "Assigned task"}]

        get :index

        response.should be_success
        data = JSON.parse(response.body)
        activity = data.first
        task.reload
        task_activity = Activity.where(:target_type => 'Task').where(:target_id => task.id).first
        pp activity

        activity['id'].should == task_activity.id
        activity['target_type'].should == 'Task'
        activity['target_id'].should == task.id
        activity['user']['username'].should == task_activity.user.login
        activity['project']['permalink'].should == task_activity.project.permalink
        activity['target']['name'].should == task.name
        activity['target']['type'].should == 'Task'
        activity['target']['id'].should == task.id
        activity['target']['is_private'].should == task.is_private
        activity['target']['comments_count'].should == task.comments_count
        activity['target']['watchers'].should == Array.wrap(task.watcher_ids)
        activity['target']['assigned_id'].should == task.assigned_id
        activity['target']['status'].should == task.status
        activity['target']['due_on'].should == task.due_on.to_s(:db)

        activity['target']['task_list']['name'].should == task.task_list.name
        activity['target']['task_list']['id'].should == task.task_list.id

        activity['target']['first_comment']['body'].should == task.first_comment.body
        activity['target']['first_comment']['id'].should == task.first_comment.id
        activity['target']['first_comment']['user']['username'].should == task.first_comment.user.login
        activity['target']['first_comment']['assigned_id'].should == task.first_comment.assigned_id
        activity['target']['first_comment']['status'].should == task.first_comment.status
        activity['target']['first_comment']['due_on'].should == task.first_comment.due_on.to_s(:db)
        activity['target']['recent_comments'].size.should == 1
        activity['target']['recent_comments'].first['id'].should == task.recent_comments.first.id
        # TODO check uploads, gdocs
      end

      it "should return nested information for a person" do
        person = Factory :person, :project => @project
        get :index

        response.should be_success
        data = JSON.parse(response.body)
        activity = data.first
        person.reload
        person_activity = Activity.where(:target_type => 'Person').where(:target_id => person.id).first

        activity['id'].should == person_activity.id
        activity['target_type'].should == 'Person'
        activity['target_id'].should == person.id

        activity['user']['username'].should == person_activity.user.login
        activity['project']['permalink'].should == person_activity.project.permalink
        activity['target']['id'].should == person.id
        activity['target']['role'].should == person.role
        activity['target']['user']['id'].should == person.user.id
      end

      it "should return nested information for a person" do
        project = Factory :project, :user => @user
        get :index

        response.should be_success
        data = JSON.parse(response.body)
        activity = data.first
        project.reload
        project_activity = Activity.where(:target_type => 'Project').where(:target_id => project.id).first

        activity['id'].should == project_activity.id
        activity['target_type'].should == 'Project'
        activity['target_id'].should == project.id

        activity['user']['username'].should == project_activity.user.login
        activity['project']['id'].should == project_activity.project.id
        activity['project']['permalink'].should == project_activity.project.permalink
        activity['target']['id'].should == project.id
      end
    end
  end
end

