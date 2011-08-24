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

    it "shows no tasks in archived projects" do
      login_as @user
      @project.update_attributes :archived => true

      get :index
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 0
    end

    it "shows tasks with a JSONP callback" do
      login_as @user

      get :index, :project_id => @project.permalink, :callback => 'lolCat', :format => 'js'
      response.should be_success

      response.body.split('(')[0].should == 'lolCat'
    end

    it "shows tasks as JSON when requested with :text format" do
      login_as @user

      get :index, :project_id => @project.permalink, :callback => 'lolCat', :format => 'text'
      response.should be_success
      response.headers['Content-Type'][/text\/plain/].should_not be_nil

      JSON.parse(response.body)['objects'].length.should == 2
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

    it "shows tasks assigned to a person" do
      login_as @user

      person = @project.people.find_by_user_id(@user)
      task = Factory.create(:task, :project => @project, :user => @user)
      task.comments_attributes = {'0' => {:user_id => @user.id, :body => 'TEST'}}
      task.assigned_id = person.id
      task.status = Task::STATUSES[:open]
      task.save!

      get :index, :assigned_id => person.id

      objects = JSON.parse(response.body)['objects']
      objects.length.should == 1
      objects[0]['id'].to_i.should == task.id
    end

    it "shows tasks assigned to a user" do
      login_as @user

      person = @project.people.find_by_user_id(@user)
      task = Factory.create(:task, :project => @project, :user => @user)
      task.comments_attributes = {'0' => {:user_id => @user.id, :body => 'TEST'}}
      task.assigned_id = person.id
      task.status = Task::STATUSES[:open]
      task.save!

      get :index, :assigned_user_id => @user.id

      objects = JSON.parse(response.body)['objects']
      objects.length.should == 1
      objects[0]['id'].to_i.should == task.id
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

    it "does not show unwatched private tasks in a project" do
      login_as @user
      @task.update_attribute(:is_private, true)

      get :index, :project_id => @project.permalink
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 1
    end
  end

  describe "#show" do
    it "shows a task with references" do
      login_as @user

      @task.update_attributes(:comments_attributes => {'0' => {:body => 'Nice task'}})

      get :show, :project_id => @project.permalink, :id => @task.id
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}

      data['id'].to_i.should == @task.id
      references.include?("#{@project.id}_Project").should == true
      references.include?("#{@task.user_id}_User").should == true
      references.include?("#{@task.first_comment.user_id}_User").should == true
      references.include?("#{@task.first_comment.id}_Comment").should == true
      @task.recent_comments.each do |comment|
        references.include?("#{comment.id}_Comment").should == true
        references.include?("#{comment.user_id}_User").should == true
      end
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

    it "does not show private tasks unwatched by the user" do
      login_as @user
      @task.update_attribute(:is_private, true)

      get :show, :project_id => @project.permalink, :id => @task.id
      response.status.should == 401
    end

    it "shows private tasks watched by the user" do
      login_as @user
      @task.add_watcher(@user)
      @task.update_attribute(:is_private, true)

      get :show, :project_id => @project.permalink, :id => @task.id
      response.should be_success

      JSON.parse(response.body)['id'].to_i.should == @task.id
    end
  end

  describe "#create" do
    it "should allow participants to create tasks" do
      login_as @user

      post :create, :project_id => @project.permalink, :id => @task_list.id, :task_list_id => @task_list.id, :name => 'Another TODO!'
      response.should be_success
      
      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      
      task = Task.find_by_id(data['id'])
      task.should_not == nil
      references.include?("#{@project.id}_Project").should == true
      references.include?("#{task.user_id}_User").should == true

      @task_list.tasks(true).length.should == 2
      @task_list.tasks(true).last.name.should == 'Another TODO!'
    end
    
    it "should create an inbox in the desired project if no task list is specified" do
      login_as @user

      post :create, :project_id => @project.permalink, :id => @task_list.id, :name => 'Another TODO!'
      response.should be_success
      
      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      
      task = Task.find_by_id(data['id'])
      task.should_not == nil
      references.include?("#{@project.id}_Project").should == true
      references.include?("#{task.user_id}_User").should == true
      
      task_list = TaskList.find_by_id(data['task_list_id'])
      task_list.name.should == 'Inbox'
      task_list.tasks.first.should == task
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

    it "should use the logged in user as the modifier of the task" do
      login_as @user

      put :update, :project_id => @project.permalink, :id => @task.id, :comments_attributes => {'0' => {'body' => 'TEST'}}
      response.should be_success

      @task.reload.comments.last.user_id.should == @user.id
    end

    it "should not allow observers to modify a task" do
      login_as @observer

      put :update, :project_id => @project.permalink, :id => @task.id, :name => 'Modified'
      response.status.should == 401

      @task.reload.name.should_not == 'Modified'
    end

    it "should not allow participants not watching to modify a private task" do
      @task.update_attribute(:is_private, true)
      login_as @user

      put :update, :project_id => @project.permalink, :id => @task.id, :name => 'Modified'
      response.status.should == 401
    end
    
    it "should not allow commenters to modify the task list" do
      commenter = Factory.create(:confirmed_user)
      @project.add_user(commenter, :role => Person::ROLES[:commenter])
      
      login_as commenter

      put :update, :project_id => @project.permalink, :id => @task.id, :task_list_id => @other_list.id, :name => 'Modified'
      response.should be_success

      @task.reload.task_list_id.should == @task_list.id
    end
    
    it "should allow users to modify the task list" do
      login_as @user

      put :update, :project_id => @project.permalink, :id => @task.id, :task_list_id => @other_list.id, :name => 'Modified'
      response.should be_success

      @task.reload.task_list_id.should == @other_list.id
    end

    it "should return updated task and any references" do
      login_as @user

      put :update, :project_id => @project.permalink, :id => @task.id,
          :name => 'Modified',
          :comments_attributes => { 0 => { :body => 'modified....',
                                           :uploads_attributes => { 
                                             0 => { 
                                               :asset => mock_uploader("templates.txt", 'text/plain', "jade")
                                             }
                                           }
                                         }
                                   }

      response.should be_success

      data = JSON.parse(response.body)
      objects = data
      objects.should_not be_empty
      objects['recent_comment_ids'].should include(@task.first_comment.id)

      references = data['references']
      references.should_not be_empty
      references.map{|r| "#{r['id'].to_s}_#{r['type']}"}.include?("#{@task.first_comment.id}_Comment")
      references.any? {|ref| ref.key?('uploads') }.should == true
      references.detect{|ref| ref.key?('uploads')}['uploads'].should_not be_empty
      references.detect{|ref| ref.key?('uploads')}['uploads'].first['download'].include?('templates.txt').should be_true
      references.detect{|ref| ref.key?('uploads')}['uploads'].first['mime_type'].should == 'text/plain'
      references.detect{|ref| ref.key?('uploads')}['uploads'].first['filename'].should == 'templates.txt'
    end
  end

  describe "#watch" do
    it "should allow participants watch a task" do
      login_as @user

      put :watch, :project_id => @project.permalink, :id => @task.id
      response.should be_success

      @task.reload.watcher_ids.include?(@user.id).should == true
    end

    it "should not allow observers to watch a task" do
      login_as @observer

      put :watch, :project_id => @project.permalink, :id => @task.id
      response.status.should == 401

      @task.reload.watcher_ids.include?(@observer.id).should_not == true
    end

    it "should not allow participants to watch private conversations" do
      @task.update_attribute(:is_private, true)
      login_as @user

      put :watch, :project_id => @project.permalink, :id => @task.id
      response.status.should == 401
    end
  end

  describe "#unwatch" do
    it "should allow participants to unwatch a task" do
      login_as @owner

      put :unwatch, :project_id => @project.permalink, :id => @task.id
      response.should be_success

      @task.reload.watcher_ids.include?(@owner.id).should_not == true
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

    it "should not allow admins not watching to modify a private task" do
      @task.update_attribute(:is_private, true)
      login_as @admin

      put :destroy, :project_id => @project.permalink, :id => @task.id
      response.status.should == 401
    end
  end

  describe "#reorder" do

    before do
      @tl = Factory(:task_list, :project => @project)
    end

    it "should allow a user to reorder tasks" do
      login_as @user
      task1 = Factory(:task, :task_list => @tl, :project => @project)
      task2 = Factory(:task, :task_list => @tl, :project => @project)
      task3 = Factory(:task, :task_list => @tl, :project => @project)
      task1.position.should == 0
      task2.position.should == 1
      task3.position.should == 2

      put :reorder, :project_id => @project.permalink, :id => task1.id, :task_list_id => @tl.id, :task_ids => [task2.id, task1.id, task3.id].join(',')
      response.should be_success

      task2.reload.position.should == 0
      task1.reload.position.should == 1
      task3.reload.position.should == 2
    end

    it "should return not found for unexisting tasks" do
      login_as @user
      put :reorder, :project_id => @project.permalink, :id => 9999999, :task_list_id => @tl.id, :task_ids => 9999999
      response.status.should == 404
    end
  end
end
