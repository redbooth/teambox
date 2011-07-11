require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController do
  before do
    @user = Factory(:confirmed_user)
    @project = Factory(:project)
    @project.add_user @user
  end

  describe "#create" do
    it "should set the current user as the author" do
      @jordi = Factory.create(:confirmed_user, :login => 'jordi')
      conversation = Factory(:conversation, :user => @jordi, :project => @project)
      Comment.last.user.should == @jordi

      login_as @user
      xhr :post, :create,
           :project_id => @project.permalink,
           :conversation_id => conversation.id,
           :comment => { :body => "Ieee" }

      Comment.last.user.should == @user
    end
  end
  
  describe "#destroy rollback" do
    before do
      task_comment_rollback_example(@project)
    end
    
    it "reverts the status back to the previous status when destroyed as the last comment with do_rollback" do
      login_as @project.user
      put :destroy, :project_id => @project.permalink, :task_id => @task.id, :id => @task.comments.last.id
      
      @task = Task.find_by_id(@task.id)
      @task.due_on.should == @old_time
      @task.assigned_id.should == @old_assigned_id
      @task.status.should == @old_status
    end
    
    it "maintains the status if any other comments are destroyed" do
      login_as @project.user
      put :destroy, :project_id => @project.permalink, :task_id => @task.id, :id => @task.comments[1].id
      
      @task = Task.find_by_id(@task.id)
      @task.due_on.should == @new_time
      @task.status.should == @new_status
      @task.assigned_id.should == @new_assigned_id
    end
  end
end
