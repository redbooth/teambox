require 'spec_helper'

describe ApiV1::CommentsController do
  before do
    make_a_typical_project
    
    @comment = @project.new_comment(@user, @project, {:body => 'Something happened!'})
    @comment.save!
  end
  
  describe "#index" do
    it "shows comments in the project" do
      login_as @user
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
      JSON.parse(response.body).length.should == 1
    end
    
    it "shows comments on a task" do
      login_as @user
      
      task = Factory.create(:task, :project => @project)
      comment = @project.new_comment(@user, task, {:body => 'Something happened!'})
      comment.save!
      
      get :index, :project_id => @project.permalink, :task_id => task.id
      response.should be_success
      
      JSON.parse(response.body).map{|a| a['id'].to_i}.should == task.comment_ids.sort
    end
    
    it "limits comments" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :count => 1
      response.should be_success
      
      JSON.parse(response.body).length.should == 1
    end
    
    it "limits and offsets comments" do
      login_as @user
      
      other_comment = @project.new_comment(@user, @project, {:body => 'Something else happened!'})
      other_comment.save!
      
      get :index, :project_id => @project.permalink, :since_id => @project.comment_ids[1], :count => 1
      response.should be_success
      
      JSON.parse(response.body).map{|a| a['id'].to_i}.should == [@project.reload.comment_ids[0]]
    end
  end
  
  describe "#show" do
    it "shows a comment" do
      login_as @user
      
      get :show, :project_id => @project.permalink, :id => @comment.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @comment.id
    end
  end
  
  describe "#create" do
    it "show allow commenters to post a comment in a task" do
      login_as @project.user
      
      task = Factory.create(:task, :project => @project)
      task.comments.length.should == 0
      
      post :create, :project_id => @project.permalink, :task_id => task.id, :comment => {:body => 'Created!'}
      response.should be_success
      
      task.reload.comments.length.should == 1
    end
    
    it "show allow commenters to post a comment in a conversation" do
      login_as @project.user
      
      conversation = Factory.create(:conversation, :project => @project)
      conversation.comments.length.should == 1
      
      post :create, :project_id => @project.permalink, :conversation_id => conversation.id, :comment => {:body => 'Created!'}
      response.should be_success
      
      conversation.reload.comments.length.should == 2
    end
    
    it "should not allow observers to post a comment" do
      login_as @observer
      
      conversation = Factory.create(:conversation, :project => @project)
      conversation.comments.length.should == 1
      
      post :create, :project_id => @project.permalink, :conversation_id => conversation.id, :comment => {:body => 'Created!'}
      response.status.should == '401 Unauthorized'
      
      conversation.reload.comments(true).length.should == 1
    end
  end
end