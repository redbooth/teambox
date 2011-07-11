require 'spec_helper'

describe Comment do

  it { should validate_presence_of :user }

  describe "factories" do
    it "should generate a valid comment" do
      @project = Factory(:project)
      @user = @project.user
      comment = Factory.build(:comment, :project => @project, :user => @user, :target => @project)
      comment.save.should be_true
      comment.user.should == @user
      @project.comments.last.should == comment
      @user.comments.last.should == comment
    end
  end
  
  it "should not allow comment creation with a blank title" do
    comment = Factory.build(:comment, :body => nil)
    comment.should_not be_valid
  end
  
  describe "copying ownership" do
    before do
      @target = Factory.build(:simple_conversation, :body => nil)
      @target.save(:validate => false)
      @comment = Factory.build(:comment, :target => @target, :user => nil, :project => nil)
    end
    
    it "inherits project and user from target" do
      @comment.save.should be_true
      @comment.user.should == @target.user
      @comment.project.should == @target.project
    end
    
    it "works even when mentioning user" do
      @comment.body = "Hello @kitty"
      lambda { @comment.save }.should_not raise_error
    end
    
    it "doesn't happen when updating" do
      new_user = Factory.create(:user)
      new_project = Factory.create(:project, :user => new_user)
      
      @comment.save
      @comment.should_not be_new_record
      @comment.user = new_user
      @comment.project = new_project
      @comment.save!
      @comment.reload
      @comment.user_id.should == new_user.id
      @comment.project_id.should == new_project.id
      @comment.body = "I am anonymous"
      @comment.save
      @comment.reload.user.should == new_user
      @comment.project.should == new_project
    end
  end
  
  describe "posting to a task" do
    before do
      @task = Factory(:task)
    end
    
    it "should update counter cache" do
      lambda {
        Factory(:comment, :project => @task.project, :user => @task.user, :target => @task)
        @task.reload
      }.should change(@task, :comments_count).by(1)
    end
  end

  describe "mentioning @user" do
    before do
      @project = Factory(:project)
      @user = Factory(:confirmed_user, :login => 'existing')
    end

    it "should link to users page when mentioning @existing if they are in the project" do
      @project.add_user(@user)
      body = "@existing, hey, @existing"
      comment = Factory(:comment, :body => body, :project => @project, :user => @project.user, :target => @project)
      comment.body_html.should == %Q{<p><a href="/users/existing" class="mention">@existing</a>, hey, <a href="/users/existing" class="mention">@existing</a></p>\n}
      comment.mentioned.to_a.should == [@user]
    end

    it "should not link a user if his username is part of an email address" do
      @project.add_user(@user)
      body = "@existing links, but not an@existing.com email"
      comment = Factory(:comment, :body => body, :project => @project, :user => @project.user, :target => @project)
      comment.body_html.should == %Q{<p><a href=\"/users/existing\" class=\"mention\">@existing</a> links, but not <a href=\"mailto:an@existing.com\">an@existing.com</a> email</p>\n}
      comment.mentioned.to_a.should == [@user]
    end

    it "should link to all the mentioned users if they are in the project" do
      pablo = Factory(:confirmed_user, :login => "pablo")
      james = Factory(:confirmed_user, :login => "james")
      @project.add_user(pablo)
      @project.add_user(james)
      body = "@pablo @james Check this out!"
      comment = Factory(:comment, :body => body, :project => @project, :user => @project.user, :target => @project)
      comment.body_html.should == %Q{<p><a href="/users/pablo" class="mention">@pablo</a> <a href="/users/james" class="mention">@james</a> Check this out!</p>\n}
      comment.mentioned.should include(pablo)
      comment.mentioned.should include(james)
    end

    it "should add everyone to watchers if @all is mentioned" do
      pablo = Factory(:confirmed_user, :login => "pablo")
      james = Factory(:confirmed_user, :login => "james")
      @project.add_user(pablo)
      @project.add_user(james)
      body = "@all hands on deck this Friday"
      comment = Factory(:comment, :body => body, :project => @project, :user => @project.user, :target => @project)
      comment.body_html.should == %Q{<p><span class="mention">@all</span> hands on deck this Friday</p>\n}
      comment.mentioned.should include(pablo)
      comment.mentioned.should include(james)
      comment.mentioned.should_not include(@user)
    end

    describe "commenting adds you as a watcher" do
      before do
        @project = Factory(:project)
        @pablo = Factory(:confirmed_user)
        @project.add_user(@pablo)
      end

      it "on a conversation" do
        conversation = Factory(:conversation, :project => @project, :user => @project.user)
        conversation.watcher_ids.should_not include(@pablo.id)
        comment = Factory(:comment, :project => @project, :user => @pablo, :target => conversation)
        conversation.reload.watcher_ids.should include(@pablo.id)
      end

      it "on a task" do
        @task = Factory(:task, :project => @project, :user => @project.user)
        @task.watcher_ids.should_not include(@pablo.id)
        comment = Factory(:comment, :project => @project, :user => @pablo, :target => @task)
        @task.reload.watcher_ids.should include(@pablo.id)
      end
    end
    
    describe "mentioning @user" do
      before do
        @project.add_user(@user)
      end

      it "should add him to conversation" do
        @conversation = Factory(:conversation, :project => @project, :user => @project.user)
        @conversation.watchers.should_not include(@user)

        body = "I would like to add @existing to this, but not @unexisting."
        comment = Factory(:comment, :body => body, :project => @project, :user => @project.user, :target => @conversation)
        
        comment.mentioned.to_a.should == [@user]
        @conversation.reload.watchers.should include(@user)
      end

      it "should add him to task" do
        @task = Factory(:task, :project => @project, :user => @project.user)
        @task.watchers.should_not include(@user)

        body = "I would like to add @existing to this, but not @unexisting."
        comment = Factory(:comment, :body => body, :project => @project, :user => @project.user, :target => @task)
        
        comment.mentioned.to_a.should == [@user]
        @task.reload.watchers.should include(@user)
      end
    end

    it "should not link to users page when mentioning @existing if they are not in the project" do
      body = "@existing is a cool guy, but he is not in this project"
      comment = Factory.create(:comment, :body => body, :project => @project, :user => @project.user, :target => @project)
      comment.body_html.should == "<p>@existing is a cool guy, but he is not in this project</p>\n"
      comment.mentioned.should == nil
    end

    it "should not link to users page when typing @unexisting" do
      body = "Hey, @unexisting, take a look at this!"
      comment = Factory.create(:comment, :body => body, :project => @project, :user => @project.user, :target => @project)
      comment.body_html.should == "<p>Hey, @unexisting, take a look at this!</p>\n"
      comment.mentioned.should == nil
    end
  end
  
  describe "duplicates" do
    before do
      @project = Factory(:project)
      @user = @project.user
      @comment = Factory(:comment, :project => @project, :user => @user, :target => @project)
    end

    it "should not allow posting a duplicate comment" do
      comment = Factory.build(:comment, :project => @project, :user => @user, :target => @project, :body => @comment.body)
      comment.valid?.should be_false
    end

    it "should allow posting a comment with the same body to different targets" do
      @task = Factory(:task)
      lambda {
        Factory(:comment, :project => @project, :user => @user, :target => @task, :body => @comment.body)
      }.should change(Comment, :count).by(1)
    end
  end
  
  describe "commenting updates the updated_at field" do
    before do
      @project = Factory(:project)
      @user = @project.user
    end
    
    it "on a conversation" do
      conversation = Factory(:conversation, :project => @project, :user => @project.user)
      conversation.update_attribute :updated_at, 1.day.ago
      lambda {
        Factory(:comment, :project => @project, :user => @user, :target => conversation)
        conversation.reload
      }.should change(conversation, :updated_at)
    end
    
    it "on a task" do
      task = Factory(:task, :project => @project, :user => @project.user)
      task.update_attribute :updated_at, 1.day.ago
      lambda {
        Factory(:comment, :project => @project, :user => @user, :target => task)
        task.reload
      }.should change(task, :updated_at)
    end
  end
  
  describe "destruction" do
    before do
      task_comment_rollback_example(Factory(:project))
    end
    
    it "reverts the status back to the previous status when destroyed as the last comment with do_rollback" do
      @task.comments.last.do_rollback = true
      @task.comments.last.destroy
      
      @task = Task.find_by_id(@task.id)
      @task.due_on.should == @old_time
      @task.assigned_id.should == @old_assigned_id
      @task.status.should == @old_status
    end
    
    it "maintains the status if any other comments are destroyed" do
      @task.comments[1].do_rollback = true
      @task.comments[1].destroy
      
      @task = Task.find_by_id(@task.id)
      @task.due_on.should == @new_time
      @task.status.should == @new_status
      @task.assigned_id.should == @new_assigned_id
    end
  end
  
  describe "permissions" do
    before do
      @project = Factory(:project)
      @user = Factory(:confirmed_user, :login => 'existing')
      @other_user = Factory(:confirmed_user, :login => 'existing2')
      @another_user = Factory(:confirmed_user, :login => 'existing3')
      @comment = Factory(:comment, :body => "Random comment.", :project => @project, :user => @other_user, :target => @project)
      @project.add_user(@user)
      @project.add_user(@other_user)
      @project.add_user(@another_user)
      @project.people.find_by_user_id(@user.id).update_attribute(:role, 3) # -> admin
      
      @owner_ability = Ability.new(@comment.user)
      @admin_ability = Ability.new(@user)
      @another_ability = Ability.new(@another_user)
    end
    
    it "should be editable and deletable by the creator for only 15 minutes" do
      @owner_ability.should be_able_to(:edit, @comment)
      @owner_ability.should be_able_to(:destroy, @comment)
      
      # backdate to simulate elapsed time
      @comment.update_attribute :created_at, 16.minutes.ago
      
      @owner_ability.should_not be_able_to(:edit, @comment)
      @owner_ability.should_not be_able_to(:destroy, @comment)
    end
    
    it "should not be editable by an admin" do
      @owner_ability.should be_able_to(:edit, @comment)
      @admin_ability.should_not be_able_to(:edit, @comment)
    end
    
    it "should be deletable by an admin forever" do
      @admin_ability.should be_able_to(:destroy, @comment)
      
      # backdate to simulate elapsed time
      @comment.update_attribute :created_at, 16.minutes.ago
      
      @admin_ability.should be_able_to(:destroy, @comment)
    end
    
    it "should not be editable or deletable by another non-admin" do
      @another_ability.should_not be_able_to(:edit, @comment)
      @another_ability.should_not be_able_to(:destroy, @comment)
    end
  end

  context "uploads" do
    it "should link existing upload" do
      upload = Factory.create :upload
      comment = Factory.create :comment, :upload_ids => [upload.id.to_s],
        :body => 'Here is that cat video I promised',
        :project => upload.project, :user => upload.user

      comment.uploads.should == [upload]
      upload.reload
      upload.comment.should == comment
      upload.description.should == 'Here is that cat video I promised'
    end

    it "should create nested upload" do
      attributes = { :asset => File.open(File.expand_path('../../fixtures/tb-space.jpg', __FILE__)) }
      comment = Factory.create :comment, :uploads_attributes => [attributes],
        :body => 'Here is that dog video I promised'

      comment.should have(1).upload
      upload = comment.uploads.first
      upload.comment.should == comment
      upload.description.should == 'Here is that dog video I promised'
      upload.user_id.should == comment.user_id
      upload.project_id.should == comment.project_id
    end
    
    it "should allow the creation of a comment with a file but no body" do
      upload = Factory.create :upload
      comment = Factory.create :comment, :upload_ids => [upload.id.to_s],
                                         :body => nil,
                                         :project => upload.project
      
      comment.should have(1).upload
      upload = comment.uploads.first
      upload.comment.should == comment
    end
    
    it "should allow you to delete the upload and keep the comment if there is a body" do
      upload = Factory.create :upload
      comment = Factory.create :comment, :upload_ids => [upload.id.to_s],
                                         :body => 'test',
                                         :project => upload.project
      
      comment.should have(1).upload
      comment.uploads.first.destroy
      comment.reload
      comment.body.should == 'test' # Still has the right body
      comment.should have(0).uploads
    end
    
    it "should not set a deleted message on the comment if there is still a file remaining" do
      upload1, upload2 = Factory.create(:upload), Factory.create(:upload)
      comment = Factory.create :comment, :upload_ids => [upload1.id.to_s, upload2.id.to_s], :body => nil
      
      comment.should have(2).uploads
      
      lambda do
        comment.uploads.first.destroy
      end.should_not raise_error
      
      comment.reload.should have(1).uploads
    end
    
    it "should allow you to delete the upload and keep the comment if there is no body" do
      upload = Factory.create :upload
      comment = Factory.create :comment, :upload_ids => [upload.id.to_s], :body => nil, :project => upload.project
      
      comment.should have(1).upload
      
      lambda do
        comment.uploads.first.destroy
      end.should_not raise_error
      
      comment.reload.should have(0).uploads
      comment.body.should == "File deleted"
    end
    
    it "touches comment on upload destroy" do
      upload = Factory.create :upload
      comment = Factory.create :comment, :upload_ids => [upload.id.to_s],
        :body => "Can't touch this"
      Comment.update_all({:updated_at => 15.minutes.ago}, :id => comment.id)

      comment.reload.updated_at.should be_within(5).of(15.minutes.ago)
      upload.reload.destroy
      comment.reload.updated_at.should be_within(5).of(Time.now)
    end
  end
  
  context "hours" do
    it "assigns human hours" do
      comment = Factory.build :comment, :human_hours => "2:30"
      comment.hours.should be_within(0.001).of(2.5)
      comment.human_hours = " "
      comment.hours.should be_nil
    end
  end

  context "deleting users" do
    before do
      assigned = Factory :user, :first_name => "Michael", :last_name => "Jackson"
      project = Factory :project
      @person = Factory :person, :user => assigned, :project => project
      @comment = Factory :comment, :target => Factory(:task), :user => Factory(:mislav), :assigned => @person, :project => project
      @user = @comment.user
    end

    it "should display information about the user after this being deleted" do
      @user.destroy
      @comment.reload.user.name.should == "Mislav Marohnić"
    end

    it "should display information about the assigned user after this being deleted" do
      @person.destroy
      @comment.reload.assigned.user.name.should == "Michael Jackson"
    end

    it "should display information about the previous assigned user after this being deleted" do
      comment = Factory :comment, :target => @comment.target, :assigned => Factory(:person, :project => @comment.target.project), :previous_assigned => @person
      @person.destroy
      comment.reload.previous_assigned.user.name.should == "Michael Jackson"
    end
  end
end
