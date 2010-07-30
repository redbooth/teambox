require 'spec_helper'

describe ApiV1::TaskListsController do
  before do
    make_a_typical_project
    
    @task_list = @project.create_task_list(@owner, {:name => 'A TODO list'})
    @task_list.save!
  end
  
  describe "#index" do
    it "shows task lists in the project" do
      login_as @user
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
      JSON.parse(response.body).length.should == 1
    end
    
    it "limits and offsets task lists" do
      login_as @user
      
      other_list = @project.create_task_list(@user, {:name => 'Limited TODO list'})
      other_list.save!
      
      get :index, :project_id => @project.permalink, :since_id => @project.task_list_ids[1], :count => 1
      response.should be_success
      
      JSON.parse(response.body).map{|a| a['id'].to_i}.should == [@project.reload.task_list_ids[0]]
    end
  end
  
  describe "#show" do
    it "shows a task list" do
      login_as @user
      
      get :show, :project_id => @project.permalink, :id => @task_list.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @task_list.id
    end
  end
  
  describe "#create" do
    it "should allow participants to create task lists" do
      login_as @user
      
      post :create, :project_id => @project.permalink, :id => @task_list.id, :task_list => {:name => 'Another list!'}
      response.should be_success
      
      @project.task_lists(true).length.should == 2
      @project.task_lists.first.name.should == 'Another list!'
    end
    
    it "should not allow observers to create task lists" do
      login_as @observer
      
      post :create, :project_id => @project.permalink, :id => @task_list.id, :task_list => {:name => 'Another list!'}
      response.status.should == '401 Unauthorized'
      
      @project.task_lists(true).length.should == 1
    end
  end
  
  describe "#update" do
    it "should allow participants to modify a task list" do
      login_as @user
      
      put :update, :project_id => @project.permalink, :id => @task_list.id, :task_list => {:name => 'Modified'}
      response.should be_success
      
      @task_list.reload.name.should == 'Modified'
    end
    
    it "should not allow observers to modify a task list" do
      login_as @observer
      
      put :update, :project_id => @project.permalink, :id => @task_list.id, :task_list => {:name => 'Modified'}
      response.status.should == '401 Unauthorized'
      
      @task_list.reload.name.should_not == 'Modified'
    end
  end
  
  describe "#archive" do
    it "should allow participants to archive a task list" do
      login_as @user
      
      put :archive, :project_id => @project.permalink, :id => @task_list.id
      response.should be_success
      
      @task_list.reload.archived.should == true
    end
    
    it "should not allow observers to archive a task list" do
      login_as @observer
      
      put :archive, :project_id => @project.permalink, :id => @task_list.id
      response.status.should == '401 Unauthorized'
      
      @task_list.reload.archived.should_not == true
    end
    
    it "should not allow a task list to be archived twice" do
      login_as @user
      
      put :archive, :project_id => @project.permalink, :id => @task_list.id
      put :archive, :project_id => @project.permalink, :id => @task_list.id
      response.status.should == '422 Unprocessable Entity'
      
      @task_list.reload.archived.should == true
    end
  end
  
  describe "#unarchive" do
    it "should allow participants to unarchive a task list" do
      login_as @user
      
      @task_list.update_attribute(:archived, true)
      
      put :unarchive, :project_id => @project.permalink, :id => @task_list.id
      response.should be_success
      
      @task_list.reload.archived.should == false
    end
    
    it "should not allow observers to unarchive a task list" do
      login_as @observer
      
      @task_list.update_attribute(:archived, true)
      
      put :unarchive, :project_id => @project.permalink, :id => @task_list.id
      response.status.should == '401 Unauthorized'
      
      @task_list.reload.archived.should == true
    end
    
    it "should not allow a task list to be unarchived twice" do
      login_as @user
      
      put :unarchive, :project_id => @project.permalink, :id => @task_list.id
      response.status.should == '422 Unprocessable Entity'
      
      @task_list.reload.archived.should == false
    end
  end
  
  describe "#destroy" do
    it "should allow participants to destroy a task list" do
      login_as @user
      
      put :destroy, :project_id => @project.permalink, :id => @task_list.id
      response.should be_success
      
      @project.task_lists(true).length.should == 0
    end
    
    it "should not allow observers to destroy a task list" do
      login_as @observer
      
      put :destroy, :project_id => @project.permalink, :id => @task_list.id
      response.status.should == '401 Unauthorized'
      
      @project.task_lists(true).length.should == 1
    end
  end
end