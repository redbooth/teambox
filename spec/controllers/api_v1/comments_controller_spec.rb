require 'spec_helper'

describe ApiV1::CommentsController do
  before do
    make_a_typical_project

    @target = Factory.create(:conversation, :project => @project, :user => @user)
    @comment = @target.comments.first
  end

  describe "#index" do
    it "shows comments in the project" do
      login_as @user

      get :index, :project_id => @project.permalink
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 1
    end

    it "shows comments with a JSONP callback" do
      login_as @user

      get :index, :project_id => @project.permalink, :callback => 'lolCat', :format => 'js'
      response.should be_success

      response.body.split('(')[0].should == 'lolCat'
    end

    it "shows comments as JSON when requested with the :text format" do
      login_as @user

      get :index, :project_id => @project.permalink, :format => 'text'
      response.should be_success
      response.headers['Content-Type'][/text\/plain/].should_not be_nil

      JSON.parse(response.body)['objects'].length.should == 1
    end

    it "shows comments in all projects" do
      login_as @user

      comment = Factory.create(:comment, :project => Factory.create(:project))
      comment.project.add_user(@user)

      get :index
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 2
    end

    it "shows no comments for archived projects" do
      login_as @user
      @project.update_attribute :archived, true

      get :index
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 0
    end

    it "shows comments created by a user" do
      login_as @user

      comment = Factory.create(:comment, :project => Factory.create(:project))
      comment.project.add_user(@user)

      get :index, :user_id => @user.id
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 1
    end

    it "shows no comments created by a ficticious user" do
      login_as @user

      comment = Factory.create(:comment, :project => Factory.create(:project))
      comment.project.add_user(@user)

      get :index, :user_id => -1
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 0
    end

    it "shows comments on conversations" do
      login_as @user
      conversation = Factory.create(:conversation, :project => @project)

      get :index, :project_id => @project.permalink, :conversation_id => conversation.id
      response.should be_success
      conversation_comments = JSON.parse(response.body)['objects']

      conversation_comments.map{|a| a['id'].to_i}.should == conversation.comment_ids.sort
    end

    it "shows comments on tasks" do
      login_as @user
      task = Factory.create(:task, :project => @project)
      comment = @project.new_comment(@user, task, {:body => 'Something happened!'})
      comment.save!
      task.reload

      get :index, :project_id => @project.permalink, :task_id => task.id
      response.should be_success
      task_comments = JSON.parse(response.body)['objects']

      task_comments.map{|a| a['id'].to_i}.should == task.comment_ids.sort
    end

    it "shows comments on tasks only when set" do
      login_as @user

      conversation = Factory.create(:conversation, :project => @project)
      task = Factory.create(:task, :project => @project)
      comment = @project.new_comment(@user, task, {:body => 'Something happened!'})
      comment.save!

      get :index, :project_id => @project.permalink, :target_type => 'Task'
      response.should be_success
      task_comments = JSON.parse(response.body)['objects']

      task_comments.map{|a| a['target_type']}.uniq.should == ['Task']
    end

    it "shows comments on conversations with the basic routes" do
      login_as @user
      conversation = Factory.create(:conversation, :project => @project)

      get :index, :conversation_id => conversation.id
      response.should be_success
      conversation_comments = JSON.parse(response.body)['objects']

      conversation_comments.map{|a| a['id'].to_i}.should == conversation.comment_ids.sort
    end

    it "shows comments on tasks with the basic routes" do
      login_as @user
      task = Factory.create(:task, :project => @project)
      comment = @project.new_comment(@user, task, {:body => 'Something happened!'})
      comment.save!
      task.reload

      get :index, :task_id => task.id
      response.should be_success
      task_comments = JSON.parse(response.body)['objects']

      task_comments.map{|a| a['id'].to_i}.should == task.comment_ids.sort
    end

    it "shows returns 404's for ficticious targets" do
      login_as @user

      get :index, :conversation_id => 123
      response.status.should == 404
    end

    it "shows no comments for private objects" do
      login_as @observer
      conversation = Factory.create(:conversation, :project => @project)
      conversation.update_attribute(:is_private, true)

      get :index, :conversation_id => conversation.id
      response.status.should == 401
    end

    it "limits comments" do
      login_as @user

      get :index, :project_id => @project.permalink, :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 1
    end

    it "limits and offsets comments" do
      login_as @user

      other_comment = @project.new_comment(@user, @project, {:body => 'Something else happened!'})
      other_comment.save!

      get :index, :project_id => @project.permalink, :since_id => @project.comment_ids[1], :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.should == [@project.reload.comment_ids[0]]
    end

    it "returns references for linked objects" do
      login_as @user

      controller.stub!(:api_limit).and_return(5)

      person = @project.people.find_by_user_id(@user.id)
      other_person = @project.people.find_by_user_id(@project.user_id)

      task = Factory.create(:task, :project => @project, :user => @user)
      task.comments.create_by_user(@user, {:body => 'TEST', :assigned => person}).save!
      6.times { |i| task.comments.create_by_user(@user, {:body => "Errm #{i}", :assigned => nil}).save!}

      task = Task.find_by_id(task.id)
      task.updating_user = @user
      task.assigned = other_person
      task.comments_attributes = {'0' => {:body => 'TEST!!'}}
      task.save!
      task.reload.assigned.should == other_person

      get :index, :project_id => @project.permalink
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      activities = data['objects']

      references.include?("#{@project.id}_Project").should == true
      references.include?("#{@comment.user_id}_User").should == true
      references.include?("#{@comment.user_id}_User").should == true
      references.include?("#{other_person.id}_Person").should == true
      references.include?("#{person.id}_Person").should == false # off the list
    end

    it "does not show unwatched private comments in a project" do
      login_as @owner
      @target.update_attribute(:is_private, true)

      get :index
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 0
    end
  end

  describe "#show" do
    it "shows a comment with references" do
      login_as @user

      get :show, :project_id => @project.permalink, :id => @comment.id
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}

      data['id'].to_i.should == @comment.id

      references.include?("#{@project.id}_Project").should == true
      references.include?("#{@comment.user_id}_User").should == true
      references.include?("#{@target.id}_Conversation").should == true
    end

    it "shows a comment in any project" do
      login_as @user

      get :show, :id => @comment.id
      response.should be_success

      JSON.parse(response.body)['id'].to_i.should == @comment.id
    end

    it "does not show a comment in another project" do
      login_as @user

      other_comment = Factory.create(:comment)

      get :show, :id => other_comment.id
      response.should_not be_success
    end

    it "does not show private comments with targets unwatched by the user" do
      login_as @owner
      @target.update_attribute(:is_private, true)

      get :show, :project_id => @project.permalink, :id => @target.comment_ids.first
      response.status.should == 401
    end

    it "shows private private comments with targets watched by the user" do
      login_as @owner
      @target.add_watcher(@owner)
      @target.update_attribute(:is_private, true)

      get :show, :project_id => @project.permalink, :id => @target.comment_ids.first
      response.should be_success

      JSON.parse(response.body)['id'].to_i.should == @target.comment_ids.first
    end
  end

  describe "#create" do
    it "show allow commenters to post a comment in a task" do
      login_as @project.user

      task = Factory.create(:task, :project => @project)
      task.comments.length.should == 0

      post :create, :project_id => @project.permalink, :task_id => task.id, :body => 'Created!'
      response.should be_success

      task.reload.comments.length.should == 1
    end

    it "show allow commenters to post a comment in a conversation" do
      login_as @project.user

      conversation = Factory.create(:conversation, :project => @project)
      conversation.comments.length.should == 1

      post :create, :project_id => @project.permalink, :conversation_id => conversation.id, :body => 'Created!'
      response.should be_success

      conversation.reload.comments.length.should == 2
    end

    it "should not allow observers to post a comment" do
      login_as @observer

      conversation = Factory.create(:conversation, :project => @project)
      conversation.comments.length.should == 1

      post :create, :project_id => @project.permalink, :conversation_id => conversation.id, :body => 'Created!'
      response.status.should == 401
      JSON.parse(response.body)['errors']['type'].should == 'InsufficientPermissions'

      conversation.reload.comments(true).length.should == 1
    end

    it "should not allow oauth users without :write_projects to post a comment" do
      login_as_with_oauth_scope @project.user, []

      conversation = Factory.create(:conversation, :project => @project)
      conversation.comments.length.should == 1

      post :create, :project_id => @project.permalink, :conversation_id => conversation.id, :body => 'Created!',
                    :access_token => @project.user.current_token.token
      response.status.should == 401
      JSON.parse(response.body)['errors']['type'].should == 'InsufficientPermissions'

      conversation.reload.comments.length.should == 1
    end

    it "should allow oauth users with :write_projects to post a comment" do
      login_as_with_oauth_scope @project.user, [:write_projects]

      conversation = Factory.create(:conversation, :project => @project)
      conversation.comments.length.should == 1

      post :create, :project_id => @project.permalink, :conversation_id => conversation.id, :body => 'Created!',
                    :access_token => @project.user.current_token.token
      response.should be_success

      conversation.reload.comments.length.should == 2
    end
  end


  describe "#update" do
    it "should allow the owner to modify a comment within 15 minutes" do
      login_as @comment.user

      put :update, :project_id => @project.permalink, :id => @comment.id, :body => 'Updated!'
      response.should be_success

      @comment.update_attribute(:created_at, Time.now - 16.minutes)

      put :update, :project_id => @project.permalink, :id => @comment.id, :body => 'Updated FAIL!'
      response.status.should == 401
    end

    it "should not allow anyone else to modify another comment" do
      login_as @project.user

      put :update, :project_id => @project.permalink, :id => @comment.id, :body => 'Updated!'
      response.status.should == 401
    end
  end

  describe "#destroy" do
    it "should allow an admin to destroy a comment" do
      login_as @project.user

      put :destroy, :project_id => @project.permalink, :id => @comment.id
      response.should be_success

      @project.comments(true).length.should == 0
    end

    it "should allow the owner to destroy a comment" do
      login_as @comment.user

      put :destroy, :project_id => @project.permalink, :id => @comment.id
      response.should be_success

      @project.comments(true).length.should == 0
    end

    it "should not allow a non-admin to destroy another comment" do
      login_as @observer

      put :destroy, :project_id => @project.permalink, :id => @comment.id
      response.status.should == 401

      @project.comments(true).length.should == 1
    end
  end
  
  describe "#destroy rollback" do
    before do
      task_comment_rollback_example(@project)
    end
    
    it "reverts the status back to the previous status when destroyed as the last comment with do_rollback" do
      login_as @project.user
      put :destroy, :project_id => @project.permalink, :id => @task.comments.last.id
      
      @task = Task.find_by_id(@task.id)
      @task.due_on.should == @old_time
      @task.assigned_id.should == @old_assigned_id
      @task.status.should == @old_status
    end
    
    it "maintains the status if any other comments are destroyed" do
      login_as @project.user
      put :destroy, :project_id => @project.permalink, :id => @task.comments[1].id
      
      @task = Task.find_by_id(@task.id)
      @task.due_on.should == @new_time
      @task.status.should == @new_status
      @task.assigned_id.should == @new_assigned_id
    end
  end
end
