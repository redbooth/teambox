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
        pp activity
        conv_activity = Activity.where(:target_type => 'Conversation').where(:target_id => conversation.id).first
        activity['id'].should == conv_activity.id
        activity['target_type'].should == 'Conversation'
        activity['target_id'].should == conversation.id
        activity['user']['username'].should == conv_activity.user.login
        activity['project']['permalink'].should == conv_activity.project.permalink
        activity['target']['name'].should == conversation.name
        activity['target']['is_private'].should == conversation.is_private
        activity['target']['comments_count'].should == conversation.comments_count
      end
    end
  end
end

