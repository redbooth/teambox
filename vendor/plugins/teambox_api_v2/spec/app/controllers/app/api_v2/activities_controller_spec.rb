require 'spec_helper'

describe ApiV2::ActivitiesController do
  before do
    make_a_typical_project

    @other_project = Factory.create(:project, :user => @observer)
    @other_project.add_user(@user)
  end

  describe "#index" do
    it "shows activities in all projects" do
      login_as @user

      get :index
      response.should be_success

      JSON.parse(response.body).map{|a| a['id'].to_i}.sort.should == (@project.activity_ids+@other_project.activity_ids).sort
    end

    it "shows activities with a JSONP callback" do
      login_as @user

      get :index, :callback => 'lolCat'
      response.should be_success

      pending "this shit works fine but it won't work if called from this spec"
      response.body.start_with?("lolCat(").should be_true
    end

    it "shows activities in a project" do
      login_as @user
      Factory :project, :user => @user

      get :index, :project_id => @project.permalink
      response.should be_success

      JSON.parse(response.body).map{|a| a['id'].to_i}.sort.should == @project.activity_ids.sort
    end

    it "shows activities by a user" do
      login_as @user

      get :index, :user_id => @user.id
      response.should be_success

      JSON.parse(response.body).map{|a| a['id'].to_i}.sort.should == (Activity.find_all_by_user_id(@user.id).map(&:id)).sort
    end

    it "shows no activities for a ficticious user" do
      login_as @user

      get :index, :user_id => -1
      response.should be_success

      JSON.parse(response.body).length.should == 0
    end

    it "limits activities" do
      login_as @user

      get :index, :project_id => @project.permalink, :count => 1
      response.should be_success

      JSON.parse(response.body).length.should == 1
    end

    it "limits activities to the hard limit" do
      login_as @user

      10.times { Factory :person, :project => @project }

      get :index, :project_id => @project.permalink, :count => 0
      response.should be_success

      JSON.parse(response.body).length.should == 10
    end

    it "limits and offsets activities" do
      login_as @user

      get :index, :project_id => @project.permalink, :since_id => @project.activity_ids[1], :count => 1
      response.should be_success

      JSON.parse(response.body).map{|a| a['id'].to_i}.should == [@project.activity_ids[0]]
    end

    it "includes nested objects" do
      login_as @user

      get :index, :project_id => @project.permalink
      response.should be_success

      data = JSON.parse(response.body)

      project = data.find { |a| a['target']['type'] == 'Project' && a['target']['id'] == @project.id }
      project.should_not be_nil
      person = data.find { |a| a['target']['type'] == 'Person' && a['target']['id'] == @project.people.last.id }
      person.should_not be_nil

    end

    it "returns comment for conversation and task objects" do
      login_as @user

      assigned_person = Factory(:person, :project => @project)
      task = Factory.create(:task, :project => @project, :user => @project.user)
      5.times { Factory.create(:comment, :target => task, :project => @project) }
      # This ensures the first activities will not be on the first page
      conversation = Factory.create(:conversation, :project => @project, :user => task.user)
      upload = Factory.build(:upload, :asset => mock_uploader('semicolons.js', 'application/javascript', "alert('what?!')"), :user => task.user)
      Factory :comment, :target => conversation, :project => @project, :uploads => [upload], :user => task.user
      task.assign_to(assigned_person.user)

      get :index, :project_id => @project.permalink
      response.should be_success

      data = JSON.parse(response.body)

      conversation_activity = data.find { |a| a['target_type'] == 'Conversation' && a['target_id'] == conversation.id }
      conversation_activity['user']['username'].should == conversation.user.login
      conversation_activity['target']['name'].should == conversation.name
      conversation_activity['target']['first_comment']['id'].should == conversation.first_comment.id
      conversation_activity['target']['first_comment']['user']['id'].should == conversation.first_comment.user.id
      conversation_activity['target']['recent_comments'].collect { |c| c['uploads'] }.compact.flatten.collect { |u| u['id'] }.should include(upload.id)

      task_activity = data.find { |a| a['target_type'] == 'Task' && a['target_id'] == task.id }
      task_activity['user']['username'].should == task.user.login
      task_activity['target']['name'].should == task.name
      task_activity['target']['first_comment']['id'].should == task.first_comment.id
      task_activity['target']['first_comment']['user']['id'].should == task.first_comment.user.id
      task_activity['target']['assigned_id'].should == assigned_person.id


      data.each do |obj|
        if obj['type'] == 'Conversation'
          obj['first_comment_id'].should == conversation.first_comment.id
          obj['recent_comment_ids'].should == conversation.recent_comment_ids
        elsif obj['type'] == 'Task'
          obj['first_comment_id'].should == task.first_comment.id
          obj['recent_comment_ids'].should == task.recent_comment_ids
        end
      end
    end

    it "should not allow oauth users without :read_projects to view activities" do
      login_as_with_oauth_scope @project.user, []
      get :index, :access_token => @project.user.current_token.token
      response.status.should == 401
    end

    it "should allow oauth users with :read_projects to view activities" do
      login_as_with_oauth_scope @project.user, [:read_projects]
      get :index, :access_token => @project.user.current_token.token
      response.should be_success
    end

    it "restricts activities by target" do
      login_as @user

      @conversation = @project.new_conversation(@owner, {:name => 'Something needs to be done'})
      @conversation.body = 'Hell yes!'
      @conversation.save!

      get :index, :target_type => 'Conversation'
      response.should be_success

      JSON.parse(response.body).map{|a| a['target_type']}.uniq.should == ['Conversation']
    end

    it "restricts activities by comment target" do
      login_as @user

      @conversation = @project.new_conversation(@owner, {:name => 'Something needs to be done'})
      @conversation.body = 'Hell yes!'
      @conversation.save!

      get :index, :comment_target_type => 'Conversation'
      response.should be_success

      JSON.parse(response.body).map{|a| a['comment_target_type']}.uniq.should == ['Conversation']
    end

    it "does not show activities for unwatched private objects" do
      login_as @user

      conversation = Factory(:conversation, :project => @project)
      conversation.update_attribute(:is_private, true)

      get :index
      response.should be_success

      list = {}
      JSON.parse(response.body).each do |object|
        list["#{object['comment_target_type']}#{object['comment_target_id']}"] = object if object['comment_target_type']
        list["#{object['target_type']}#{object['target_id']}"] = object
      end

      list["Conversation#{conversation.id}"].should == nil
    end

    it "can ask only for unique threads" do
      login_as @user

      conversation = Factory(:conversation, :project => @project, :name => "Dogshit")
      2.times { Factory.create(:comment, :target => conversation, :project => @project) }

      get :index, :threads => true
      response.should be_success
      objects = JSON.parse(response.body)
      objects.select{ |a| a['target_type'] == 'Conversation' }.should_not be_empty
      objects.select{ |a| a['target_type'] == 'Comment' }.should be_empty
    end
  end

  describe "#show" do
    it "shows an activity with references" do
      login_as @user

      activity = @project.activities.last

      get :show, :project_id => @project.permalink, :id => activity.id
      response.should be_success

      data = JSON.parse(response.body)
      data['target']['id'].should == activity.target_id
      data['target']['type'].should == activity.target_type
      data['user']['username'].should == activity.user.login
      data['project']['permalink'].should == activity.project.permalink
    end

    it "does not show an activity for an unwatched private object" do
      login_as @user

      conversation = Factory(:conversation, :project => @project)
      conversation.update_attribute(:is_private, true)

      activity = @project.activities.where(:comment_target_type => 'Conversation').order('id DESC').first

      get :show, :project_id => @project.permalink, :id => activity.id

      response.status.should == 401
    end
  end
end
