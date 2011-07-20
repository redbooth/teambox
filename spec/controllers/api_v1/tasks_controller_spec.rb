require 'spec_helper'

describe ApiV1::TasksController do
  before do
    make_a_typical_project
    
    @task_list = @project.create_task_list(@owner, {:name => 'A TODO list'})
    @task_list.save!
    
    @other_list = @project.create_task_list(@owner, {:name => 'A TODO list'})
    @other_list.save!
    
    @task = @project.create_task(@owner,@task_list,{:name => 'Something TODO'})
    @task.save!
    @other_task = @project.create_task(@owner,@other_list,{:name => 'Something else TODO'})
    @other_task.status = 3
    @other_task.save!
  end
  
  describe "#index" do
    it "shows tasks in the project" do
      login_as @user
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 2
    end
    
    it "shows tasks with a JSONP callback" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :callback => 'lolCat', :format => 'js'
      response.should be_success
      
      response.body.split('(')[0].should == 'lolCat'
    end
    
    it "shows tasks in a task list" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :task_list_id => @task_list.id
      response.should be_success
      
      JSON.parse(response.body)['objects'].map{|t| t['id'].to_i}.sort.should == @task_list.task_ids.sort
    end
    
    it "shows tasks created by a user" do
      login_as @user
      
      get :index, :user_id => @owner.id
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 2
    end
    
    it "shows no tasks created by a ficticious user" do
      login_as @user
      
      get :index, :user_id => -1
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 0
    end
    
    it "shows tasks in all the users projects" do
      login_as @user
      
      other_project_list = Factory.create(:task_list)
      other_project_list.project.add_user(@user)
      other_project_task = other_project_list.project.create_task(@user,other_project_list,{:name => 'Alternate TODO'}).save!
      
      get :index
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 3
    end
    
    it "restricts by status" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :status => [3]
      response.should be_success
      
      JSON.parse(response.body)['objects'].map{|t| t['id'].to_i}.sort.should == [@other_task.id]
    end
    
    it "limits tasks" do
      login_as @user
      
      get :index, :count => 1
      response.should be_success
      
      JSON.parse(response.body)['objects'].length.should == 1
    end
    
    it "limits and offsets tasks" do
      login_as @user
      
      get :index, :since_id => @task.id, :count => 1
      response.should be_success
      
      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.should == [@other_task.id]
    end
    
    it "returns references for linked objects" do
      login_as @user
      
      @task.comments.create_by_user(@user, {:body => 'TEST'}).save!
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      activities = data['objects']
      
      references.include?("#{@project.id}_Project").should == true
      references.include?("#{@task.user_id}_User").should == true
      references.include?("#{@task.first_comment.user_id}_User").should == true
      references.include?("#{@task.first_comment.id}_Comment").should == true
      @task.recent_comments.each do |comment|
        references.include?("#{comment.id}_Comment").should == true
        references.include?("#{comment.user_id}_User").should == true
      end
    end
  end
  
  describe "#show" do
    it "shows a task" do
      login_as @user
      
      get :show, :project_id => @project.permalink, :id => @task.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @task.id
    end
    
    it "shows a task in a task list" do
      login_as @user
      
      get :show, :project_id => @project.permalink, :task_list_id => @task_list.id, :id => @task.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @task.id
    end
    
    it "does not show a task in another list" do
      login_as @user
      
      get :show, :project_id => @project.permalink, :task_list_id => @other_list.id, :id => @task.id
      response.status.should == 404
    end
  end
  
  describe "#create" do
    it "should allow participants to create tasks" do
      login_as @user
      
      post :create, :project_id => @project.permalink, :id => @task_list.id, :task_list_id => @task_list.id, :name => 'Another TODO!'
      response.should be_success
      
      @task_list.tasks(true).length.should == 2
      @task_list.tasks(true).last.name.should == 'Another TODO!'
    end
    
    it "should not allow observers to create tasks" do
      login_as @observer
      
      post :create, :project_id => @project.permalink, :id => @task.id, :task_list_id => @task_list.id, :name => 'Another TODO!'
      response.status.should == 401
      
      @task_list.tasks(true).length.should == 1
    end
  end
  
  describe "#update" do
    it "should allow participants to modify a task" do
      login_as @user
      
      put :update, :project_id => @project.permalink, :id => @task.id, :name => 'Modified'
      response.should be_success
      
      @task.reload.name.should == 'Modified'
    end
    
    it "should not allow observers to modify a task" do
      login_as @observer
      
      put :update, :project_id => @project.permalink, :id => @task.id, :name => 'Modified'
      response.status.should == 401
      
      @task.reload.name.should_not == 'Modified'
    end
  end
  
  describe "#watch" do
    it "should allow participants watch a task" do
      login_as @user
      
      put :watch, :project_id => @project.permalink, :id => @task.id
      response.should be_success
      
      @task.reload.watchers_ids.include?(@user.id).should == true
    end
    
    it "should not allow observers to watch a task" do
      login_as @observer
      
      put :watch, :project_id => @project.permalink, :id => @task.id
      response.status.should == 401
      
      @task.reload.watchers_ids.include?(@observer.id).should_not == true
    end
  end
  
  describe "#unwatch" do
    it "should allow participants to unwatch a task" do
      login_as @owner
      
      put :unwatch, :project_id => @project.permalink, :id => @task.id
      response.should be_success
      
      @task.reload.watchers_ids.include?(@owner.id).should_not == true
    end
  end
  
  describe "#destroy" do
    it "should allow the owner to destroy a task" do
      login_as @task.user
      
      put :destroy, :project_id => @project.permalink, :id => @task.id
      response.should be_success
      
      @task_list.tasks(true).length.should == 0
    end
    
    it "should allow an admin to destroy a task" do
      login_as @admin
      
      put :destroy, :project_id => @project.permalink, :id => @task.id
      response.should be_success
      
      @task_list.tasks(true).length.should == 0
    end
    
    it "should not allow observers to destroy a task" do
      login_as @observer
      
      put :destroy, :project_id => @project.permalink, :id => @task.id
      response.status.should == 401
      
      @task_list.tasks(true).length.should == 1
    end
  end
end
