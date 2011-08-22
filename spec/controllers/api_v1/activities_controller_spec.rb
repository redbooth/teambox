require 'spec_helper'

describe ApiV1::ActivitiesController do
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

      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.sort.should == (@project.activity_ids+@other_project.activity_ids).sort
    end
    
    it "shows uploads in comments when requested" do
      login_as @user
      
      @conversation = Factory.create(:conversation, :project => @project, :body => 'Test conversation')
      @task = Factory.create(:conversation, :project => @project, :body => 'Test conversation')
      @task.updating_user = @task.user
      @task.update_attributes(:comments_attributes => {'0' => {'body' => 'Test'}})
      
      @upload = @project.uploads.new({:asset => mock_uploader('semicolons.js', 'application/javascript', "alert('what?!')")})
      @upload.comment = @conversation.comments.first
      @upload.user = @user
      @upload.save!
      
      @other_upload = @project.uploads.new({:asset => mock_uploader('jquery.js', 'application/javascript', ";")})
      @other_upload.comment = @task.comments(true).first
      @other_upload.user = @user
      @other_upload.save!

      get :index, :include => [:uploads, :google_docs]
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      references.include?("#{@upload.id}_Upload").should == true
      references.include?("#{@other_upload.id}_Upload").should == true
      
      comment_ids = [@task.comments(true).first.id, @conversation.comments.first.id]
      comments = data['references'].reject{ |o| !(o['type'] == 'Comment' && comment_ids.include?(o['id'])) }
      comments.length.should == 2
      
      comments.each do |comment|
        comment['uploads'].should_not == nil
        comment['upload_ids'].should_not == nil
      end
    end

    it "shows activities as JSON when requested with :text format" do
      login_as @user

      get :index, :format => 'text'
      response.should be_success
      response.headers['Content-Type'][/text\/plain/].should_not be_nil

      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.sort.should == (@project.activity_ids+@other_project.activity_ids).sort
    end

    it "shows activities with a JSONP callback" do
      login_as @user

      get :index, :callback => 'lolCat', :format => 'js'
      response.should be_success

      response.body.split('(')[0].should == 'lolCat'
    end

    it "shows activities in a project" do
      login_as @user

      get :index, :project_id => @project.permalink
      response.should be_success

      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.sort.should == @project.activity_ids.sort
    end

    it "shows activities by a user" do
      login_as @user

      get :index, :user_id => @user.id
      response.should be_success

      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.sort.should == (Activity.find_all_by_user_id(@user.id).map(&:id)).sort
    end

    it "shows no activities for a ficticious user" do
      login_as @user

      get :index, :user_id => -1
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 0
    end

    it "limits activities" do
      login_as @user

      get :index, :project_id => @project.permalink, :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 1
    end

    it "limits activities to the hard limit" do
      login_as @user

      10.times { Factory :person, :project => @project }

      get :index, :project_id => @project.permalink, :count => 0
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 10
    end

    it "limits and offsets activities" do
      login_as @user

      get :index, :project_id => @project.permalink, :since_id => @project.activity_ids[1], :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.should == [@project.activity_ids[0]]
    end

    it "returns references for linked objects" do
      login_as @user

      get :index, :project_id => @project.permalink, :since_id => @project.activity_ids[1], :count => 1
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      data['objects'].should_not == nil

      references.include?("#{@project.id}_Project").should == true
      references.include?("#{@project.people.last.id}_Person").should == true
    end

    it "returns comment references for conversation and task objects" do
      login_as @user

      assigned_person = Factory(:person, :project => @project)
      task = Factory.create(:task, :project => @project, :user => @project.user)
      5.times { Factory.create(:comment, :target => task, :project => @project) }
      # This ensures the first activities will not be on the first page
      conversation = Factory.create(:conversation, :project => @project, :user => task.user)
      upload = Factory.build(:upload, :asset => mock_uploader('semicolons.js', 'application/javascript', "alert('what?!')"), :user => task.user)
      Factory.create(:comment, :target => conversation, :project => @project, :uploads => [upload], :user => task.user)
      Factory :comment, :target => task, :project => @project, :assigned_id => assigned_person.id, :user => task.user

      get :index, :project_id => @project.permalink
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      data['objects'].should_not == nil

      references.include?("#{conversation.id}_Conversation").should == true
      references.include?("#{task.id}_Task").should == true
      references.include?("#{conversation.first_comment.id}_Comment").should == true
      references.include?("#{conversation.first_comment.user.id}_User").should == true
      references.include?("#{conversation.user_id}_User").should == true
      references.include?("#{task.first_comment.id}_Comment").should == true
      references.include?("#{task.first_comment.user.id}_User").should == true
      references.include?("#{task.user_id}_User").should == true
      references.include?("#{upload.id}_Upload").should == true
      references.include?("#{assigned_person.id}_Person").should == true

      data['objects'].each do |obj|
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

      JSON.parse(response.body)['objects'].map{|a| a['target_type']}.uniq.should == ['Conversation']
    end

    it "restricts activities by comment target" do
      login_as @user

      @conversation = @project.new_conversation(@owner, {:name => 'Something needs to be done'})
      @conversation.body = 'Hell yes!'
      @conversation.save!

      get :index, :comment_target_type => 'Conversation'
      response.should be_success

      JSON.parse(response.body)['objects'].map{|a| a['comment_target_type']}.uniq.should == ['Conversation']
    end

    it "does not show activities for unwatched private objects" do
      login_as @user

      conversation = Factory(:conversation, :project => @project)
      conversation.update_attribute(:is_private, true)

      get :index
      response.should be_success

      list = {}
      JSON.parse(response.body)['objects'].each do |object|
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
      objects = JSON.parse(response.body)['objects']
      objects.select{ |a| a['target_type'] == 'Conversation' }.should_not be_empty
      objects.select{ |a| a['target_type'] == 'Comment' }.should be_empty
    end

    it "shows all the threads and correctly ordered" do
      login_as @user

      conversation = Factory(:conversation, :project => @project, :name => "Old conversation", :user => @user)
      10.times { Factory(:conversation, :project => @project, :user => @user) }
      Factory.create(:comment, :target => conversation, :project => @project)

      get :index, :threads => true
      response.should be_success

      body = JSON.parse(response.body)

      first_conv_activity = Activity.where(:target_type => 'Conversation', :target_id => conversation.id).first
      body['objects'].first['id'].to_i.should == first_conv_activity.id
      conversation_reference = body['references'].find { |r| r['type'] == 'Conversation' && r['id'] == conversation.id }
      conversation_reference['name'].should == "Old conversation"
    end
  end

  describe "#show" do
    it "shows an activity with references" do
      login_as @user

      activity = @project.activities.last

      get :show, :project_id => @project.permalink, :id => activity.id
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      data['id'].to_i.should == activity.id

      references.include?("#{activity.target_id}_#{activity.target_type}").should == true
      references.include?("#{activity.user_id}_User").should == true
      references.include?("#{activity.project_id}_Project").should == true
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
