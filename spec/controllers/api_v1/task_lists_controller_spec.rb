require 'spec_helper'

describe ApiV1::TaskListsController do
  before do
    make_a_typical_project

    @task_list = @project.create_task_list(@owner, {:name => 'A TODO list'})
    @task_list.save!

    @other_task_list = @project.create_task_list(@owner, {:name => 'Another TODO list'})
    @other_task_list.archived = true
    @other_task_list.save!
  end

  describe "#index" do
    it "shows task lists in the project" do
      login_as @user
      @project.create_task(@owner,@task_list,{:name => 'Something TODO'}).save!
      @project.create_task(@owner,@other_task_list,{:name => 'Something Else TODO'}).save!

      get :index, :project_id => @project.permalink
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
      data['objects'].length.should == 2
      data['objects'].each{|o| o['tasks'].should == nil}

      references.include?("#{@project.id}_Project").should == true
      references.include?("#{@task_list.user_id}_User").should == true
      references.include?("#{@other_task_list.user_id}_User").should == true
    end
    
    describe "include" do
      before do
        login_as @user
        @first_task = @project.create_task(@owner,@task_list,{:name => 'Something TODO', 
                                                              :comments_attributes => {'0' => {'body' => 'First test comment'}}})
        @second_task = @project.create_task(@owner,@other_task_list,{:name => 'Something Else TODO',
                                                                     :assigned_id => @project.people.first.id,
                                                                     :status => Task::STATUSES[:resolved],
                                                                     :comments_attributes => {'0' => {'body' => 'Second test comment'}}})
        
        @task_list.archived_tasks.length.should == 0
        @task_list.unarchived_tasks.length.should == 1
        @other_task_list.archived_tasks.length.should == 1
        @other_task_list.unarchived_tasks.length.should == 0
      end
      
      it "shows task lists with tasks with include=tasks" do
        get :index, :project_id => @project.permalink, :include => 'tasks'
        response.should be_success

        data = JSON.parse(response.body)
        references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}

        data['objects'].each{|o| o['task_ids'].length.should == 1}
        data['references'].each{|o| o['type'].should_not == 'TaskList'}
        data['references'].reject{|r|r['type'] != 'Task'}.length.should == 2

        references.include?("#{@project.people.first.id}_Person").should == true
        references.include?("#{@project.id}_Project").should == true
        references.include?("#{@owner.id}_User").should == true
        references.include?("#{@second_task.first_comment.id}_Comment").should == true
      end

      it "shows task lists with tasks with include=unarchived_tasks" do
        get :index, :project_id => @project.permalink, :include => 'unarchived_tasks'
        response.should be_success

        data = JSON.parse(response.body)
        references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
        
        data['references'].reject{|r|r['type'] != 'Task'}.length.should == 1
        references.include?("#{@first_task.id}_Task").should == true
        references.include?("#{@first_task.first_comment.id}_Comment").should == true
      end
      
      it "shows task lists with tasks with include=archived_tasks" do
        get :index, :project_id => @project.permalink, :include => 'archived_tasks'
        response.should be_success

        data = JSON.parse(response.body)
        references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
        
        data['references'].reject{|r|r['type'] != 'Task'}.length.should == 1
        references.include?("#{@second_task.id}_Task").should == true
        references.include?("#{@second_task.first_comment.id}_Comment").should == true
      end

      it "shows a task list with tasks with include=unarchived_tasks" do
        get :show, :project_id => @project.permalink, :id => @task_list.id, :include => 'unarchived_tasks'
        response.should be_success

        data = JSON.parse(response.body)
        references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}
        
        data['task_ids'].length.should == 1
        data['references'].reject{|r|r['type'] != 'Task'}.length.should == 1
        references.include?("#{@first_task.id}_Task").should == true
        references.include?("#{@first_task.first_comment.id}_Comment").should == true
      end
    end

    it "shows task lists as JSON when requested with the :text format" do
      login_as @user

      get :index, :project_id => @project.permalink, :format => 'text'
      response.should be_success
      response.headers['Content-Type'][/text\/plain/].should_not be_nil

      JSON.parse(response.body)['objects'].length.should == 2
    end

    it "shows task lists with a JSONP callback" do
      login_as @user

      get :index, :project_id => @project.permalink, :callback => 'lolCat', :format => 'js'
      response.should be_success

      response.body.split('(')[0].should == 'lolCat'
    end

    it "shows task lists in all projects" do
      login_as @user

      task_list = Factory.create(:task_list, :project => Factory.create(:project))
      task_list.project.add_user(@user)

      get :index
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 3
    end

    it "shows no task lists for archived projects" do
      login_as @user
      @project.update_attribute :archived, true

      get :index
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 0
    end

    it "shows task lists created by a user" do
      login_as @user

      task_list = Factory.create(:task_list, :project => Factory.create(:project))
      task_list.project.add_user(@user)

      get :index, :user_id => @owner.id
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 2
    end

    it "shows no task lists created by a ficticious user" do
      login_as @user

      get :index, :user_id => -1
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 0
    end

    it "restricts by archived lists" do
      login_as @user

      get :index, :project_id => @project.permalink, :archived => true
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 1
    end

    it "restricts by unarchived lists" do
      login_as @user

      get :index, :project_id => @project.permalink, :archived => false
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 1
    end

    it "limits task lists" do
      login_as @user

      get :index, :project_id => @project.permalink, :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].length.should == 1
    end

    it "limits and offsets task lists" do
      login_as @user

      other_list = @project.create_task_list(@user, {:name => 'Limited TODO list'})
      other_list.save!

      get :index, :project_id => @project.permalink, :since_id => @project.task_list_ids[1], :count => 1
      response.should be_success

      JSON.parse(response.body)['objects'].map{|a| a['id'].to_i}.should == [@project.reload.task_list_ids[0]]
    end
  end

  describe "#show" do
    it "shows a task list with references" do
      login_as @user

      get :show, :project_id => @project.permalink, :id => @task_list.id
      response.should be_success

      data = JSON.parse(response.body)
      references = data['references'].map{|r| "#{r['id']}_#{r['type']}"}

      data['id'].to_i.should == @task_list.id

      references.include?("#{@task_list.project_id}_Project").should == true
      references.include?("#{@task_list.user_id}_User").should == true
    end
  end

  describe "#create" do
    it "should allow participants to create task lists" do
      login_as @user

      post :create, :project_id => @project.permalink, :id => @task_list.id, :name => 'Another list!'
      response.should be_success

      @project.task_lists(true).length.should == 3
      @project.task_lists.first.name.should == 'Another list!'
    end

    it "should not allow observers to create task lists" do
      login_as @observer

      post :create, :project_id => @project.permalink, :id => @task_list.id, :name => 'Another list!'
      response.status.should == 401

      @project.task_lists(true).length.should == 2
    end

    it "should allow participants to create task lists from template with optional task list name" do
      login_as @user

      @task_list_template = Factory.create(:task_list_template, :name => 'Lunch tasks template', :organization => @project.organization)

      post :create, :project_id => @project.permalink, :template_id => @task_list_template.id
      response.should be_success

      @project.task_lists(true).length.should == 3
      @project.task_lists.first.name.should == 'Lunch tasks template'


      post :create, :project_id => @project.permalink, :template_id => @task_list_template.id, :name => "Dinner tasks"
      response.should be_success

      @project.task_lists(true).length.should == 4
      @project.task_lists.first.name.should == 'Dinner tasks'

      @project.task_lists.first.tasks.last.name.should == @task_list_template.tasks.last[0]

    end

  end

  describe "#update" do
    it "should allow participants to modify a task list" do
      login_as @user

      put :update, :project_id => @project.permalink, :id => @task_list.id, :name => 'Modified'
      response.should be_success

      @task_list.reload.name.should == 'Modified'
    end

    it "should not allow observers to modify a task list" do
      login_as @observer

      put :update, :project_id => @project.permalink, :id => @task_list.id, :name => 'Modified'
      response.status.should == 401

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
      response.status.should == 401

      @task_list.reload.archived.should_not == true
    end

    it "should not allow a task list to be archived twice" do
      login_as @user

      put :archive, :project_id => @project.permalink, :id => @task_list.id
      put :archive, :project_id => @project.permalink, :id => @task_list.id
      response.status.should == 422

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
      response.status.should == 401

      @task_list.reload.archived.should == true
    end

    it "should not allow a task list to be unarchived twice" do
      login_as @user

      put :unarchive, :project_id => @project.permalink, :id => @task_list.id
      response.status.should == 422

      @task_list.reload.archived.should == false
    end
  end

  describe "#reorder" do

    it "should allow a user to reorder task lists" do
      login_as @user
      tl1 = Factory :task_list, :project => @project
      tl2 = Factory :task_list, :project => @project
      tl3 = Factory :task_list, :project => @project

      put :reorder, :project_id => @project.permalink, :task_list_ids => [tl2.id, tl3.id, tl1.id].join(',')
      response.should be_success

      tl2.reload.position.should == 0
      tl3.reload.position.should == 1
      tl1.reload.position.should == 2
    end
  end

  describe "#destroy" do
    it "should allow the creator to destroy a task list" do
      login_as @task_list.user

      put :destroy, :project_id => @project.permalink, :id => @task_list.id
      response.should be_success

      @project.task_lists(true).length.should == 1
    end

    it "should allow an admin to destroy a task list" do
      login_as @admin

      put :destroy, :project_id => @project.permalink, :id => @task_list.id
      response.should be_success

      @project.task_lists(true).length.should == 1
    end

    it "should not allow observers to destroy a task list" do
      login_as @observer

      put :destroy, :project_id => @project.permalink, :id => @task_list.id
      response.status.should == 401

      @project.task_lists(true).length.should == 2
    end
  end
end
