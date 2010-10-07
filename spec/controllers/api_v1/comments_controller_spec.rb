require 'spec_helper'

describe ApiV1::CommentsController do
  before do
    make_a_typical_project
    
    @target = Factory.create(:conversation, :project_id => @project.id, :user_id => @user.id)
    @comment = @target.comments.first
  end
  
  describe "#index" do
    it "shows comments in the project" do
      login_as @user
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
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
    
    it "shows comments on a task" do
      login_as @user
      
      task = Factory.create(:task, :project => @project)
      comment = @project.new_comment(@user, task, {:body => 'Something happened!'})
      comment.save!
      
      get :index, :project_id => @project.permalink, :task_id => task.id
      response.should be_success
      
      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.should == task.comment_ids.sort
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
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      activities = data['objects']
      
      references.include?("#{@project.id}_Project").should == true
      references.include?("#{@comment.user_id}_User").should == true
    end
  end
  
  describe "#show" do
    it "shows a comment" do
      login_as @user
      
      get :show, :project_id => @project.permalink, :id => @comment.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @comment.id
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
      response.status.should == '401 Unauthorized'
      
      conversation.reload.comments(true).length.should == 1
    end
  end
  
  
  describe "#update" do
    it "should allow the owner to modify a comment within 15 minutes" do
      login_as @comment.user
      
      put :update, :project_id => @project.permalink, :id => @comment.id, :body => 'Updated!'
      response.should be_success
      
      @comment.update_attribute(:created_at, Time.now - 16.minutes)
      
      put :update, :project_id => @project.permalink, :id => @comment.id, :body => 'Updated FAIL!'
      response.status.should == '401 Unauthorized'
    end
    
    it "should not allow anyone else to modify another comment" do
      login_as @project.user
      
      put :update, :project_id => @project.permalink, :id => @comment.id, :body => 'Updated!'
      response.status.should == '401 Unauthorized'
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
      response.status.should == '401 Unauthorized'
      
      @project.comments(true).length.should == 1
    end
  end
end