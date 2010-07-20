require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do

  describe "factories" do
    it "should generate a valid comment" do
      @project = Factory(:project)
      @user = @project.user
      comment = Factory.build(:comment, :project => @project, :user => @user, :target => @project)
      comment.save.should be_true
      comment.user.should == @user
      comment.target.should == @project
      @project.comments.last.should == comment
      @user.comments.last.should == comment
    end
  end

  describe "posting to a project" do
    before do
      @project = Factory(:project)
      @user = @project.user
    end

    it "should add it as an activity" do
      comment = Factory(:comment, :project => @project, :user => @user, :target => @project)
      @project.reload.activities.first.target.should == comment
    end

    it "should notify mentioned @user in the project" do
      @mentioned = Factory(:user)
      @project.add_user(@mentioned)
      @mentioned.notify_mentions = true
      @mentioned.save!
      comment = Factory.build(:comment, :project => @project, :user => @user, :target => @project,
        :body => "Hey @#{@mentioned.login}, how are you?")
      Emailer.should_receive(:deliver_notify_comment).with(@mentioned, @project, comment).once
      comment.save!
    end

    it "should not notify mentions to @user if he doesn't allow notifications" do
      @mentioned = Factory(:user)
      @project.add_user(@mentioned)
      @mentioned.notify_mentions = false
      @mentioned.save!
      comment = Factory.build(:comment, :project => @project, :user => @user, :target => @project,
        :body => "Hey @#{@mentioned.login}")
      Emailer.should_not_receive(:deliver_notify_comment)
      comment.save!
    end

    it "should not notify mentions to @user if he doesn't belong to the project" do
      @mentioned = Factory(:user)
      @mentioned.notify_mentions = true
      @mentioned.save!
      comment = Factory.build(:comment, :project => @project, :user => @user, :target => @project,
        :body => "Hey @#{@mentioned.login}")
      Emailer.should_not_receive(:deliver_notify_comment)
      comment.save!
    end

    it "should not notify mentions to the users who posts them" do
      @mentioned = @user
      @mentioned.notify_mentions = true
      @mentioned.save!
      comment = Factory.build(:comment, :project => @project, :user => @user, :target => @project,
        :body => "Hey @#{@mentioned.login}")
      Emailer.should_not_receive(:deliver_notify_comment)
      comment.save!
    end
  end

  describe "creating a simple conversation" do
    it "should shorten the conversation's name" do
      @project = Factory(:project)
      @user = @project.user
      body = "  Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.   "
      conversation = @project.new_conversation(@user, :simple => true)
      conversation.body = body
      conversation.save!
      conversation.name.should == "Lorem ipsum dolor sit amet, consectetur adipisi..."
    end
  end
  #describe "posting to a conversation"
  
  describe "posting to a task" do
    before do
      @task = Factory(:task)
    end
    
    it "should update counter cache" do
      lambda {
        @task.comments.create(:project => @task.project, :user_id => @task.user.id)
        @task.reload
      }.should change(@task, :comments_count).by(1)
    end
  end

  #describe "marking as read"

  describe "formatting" do
    before do
      @project = Factory(:project)
      @user = @project.user
    end

    it "should format text" do
      body = "She **used** to _mean_ so much to ME!"
      comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
      comment.body_html.should == "<p>She <strong>used</strong> to <em>mean</em> so much to ME!</p>\n"
    end

    it "should format lists" do
      body = "She used to mean:\n\n* So\n* much\n* to\n * me!"
      comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
      comment.body_html.should == "<p>She used to mean:</p>\n\n<ul>\n<li>So</li>\n<li>much</li>\n<li>to</li>\n<li>me!</li>\n</ul>\n\n"
    end

    it "should format emails and links" do
      body = 'she@couchsurfing.org used to mean so much to www.teambox.com'
      comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
      comment.body_html.should == "<p><a href=\"mailto:she@couchsurfing.org\">she@couchsurfing.org</a> used to mean so much to <a href=\"http://www.teambox.com\">www.teambox.com</a></p>\n"
    end

    it "should convert markdown links" do
      body = 'I loved that quote: ["I like the Divers, but they want me want to go to a war."](http://www.shmoop.com/tender-is-the-night/tommy-barban.html) Great page, too.'
      comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
      comment.body_html.should == %Q{<p>I loved that quote: <a href="http://www.shmoop.com/tender-is-the-night/tommy-barban.html">"I like the Divers, but they want me want to go to a war."</a> Great page, too.</p>\n}
    end

    it "should add http:// in front of links to www.site.com" do
      body = "I'd link my competitors' mistakes (www.failblog.org) but that'd give them free traffic. So instead I link www.google.com."
      comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
      comment.body_html.should == %Q{<p>I'd link my competitors' mistakes (<a href="http://www.failblog.org">www.failblog.org</a>) but that'd give them free traffic. So instead I link <a href="http://www.google.com">www.google.com</a>.</p>\n}
    end

    it "should preserve html links and images" do
      body = 'Did you know the logo from Teambox has <a href="http://en.wikipedia.org/wiki/Color_theory">carefully selected colors</a>? <img src="http://app.teambox.com/images/header_logo_large.jpg"/>'
      comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
      comment.body_html.should == %Q{<p>Did you know the logo from Teambox has <a href="http://en.wikipedia.org/wiki/Color_theory">carefully selected colors</a>? <img src="http://app.teambox.com/images/header_logo_large.jpg" /></p>\n}
    end

    it "should truncate links longer than 80 chars" do
      body = 'This commit needs a spec: http://github.com/teambox/teambox/blob/4b54c555d118cd3bc4d4d80fbc59b1eed79b4e80/lib/html_formatting.rb'
      comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
      comment.body_html.should == "<p>This commit needs a spec: <a href=\"http://github.com/teambox/teambox/blob/4b54c555d118cd3bc4d4d80fbc59b1eed79b4e80/lib/html_formatting.rb\">http://github.com/teambox/teambox/blob/4b54c555d118cd3bc4d4d80fbc59b1eed79b4e...</a></p>\n"
    end

    it "should not truncate links shorter or equal than 80 chars" do
      body = 'This commit needs a spec: http://github.com/teambox/teambox/commit/4b54c555d118cd3bc4d4d80fbc59b1eed79b4e8'
      comment = Factory.create(:comment, :body => body, :project => @project, :user => @user, :target => @project)
      comment.body_html.should == "<p>This commit needs a spec: <a href=\"http://github.com/teambox/teambox/commit/4b54c555d118cd3bc4d4d80fbc59b1eed79b4e8\">http://github.com/teambox/teambox/commit/4b54c555d118cd3bc4d4d80fbc59b1eed79b4e8</a></p>\n"
    end

    it "should preserve blocks of code and pre"

    it "should allow youtube videos"
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
      comment.mentioned.should == [@user]
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

    describe "commenting" do
      before do
        @project = Factory(:project)
        @pablo = Factory(:confirmed_user)
        @project.add_user(@pablo)
      end

      it "on a conversation should add you as a watcher" do
        @conversation = Factory(:conversation, :project => @project, :user => @project.user)
        @conversation.watchers_ids.should_not include(@pablo.id)
        comment = Factory(:comment, :project => @project, :user => @pablo, :target => @conversation)
        @conversation.reload.watchers_ids.should include(@pablo.id)
      end

      it "on a task should add you as a watcher" do
        @task = Factory(:task, :project => @project, :user => @project.user)
        @task.watchers_ids.should_not include(@pablo.id)
        comment = Factory(:comment, :project => @project, :user => @pablo, :target => @task)
        @task.reload.watchers_ids.should include(@pablo.id)
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
        
        comment.mentioned.should == [@user]
        @conversation.reload.watchers.should include(@user)
      end

      it "should add him to task" do
        @task = Factory(:task, :project => @project, :user => @project.user)
        @task.watchers.should_not include(@user)

        body = "I would like to add @existing to this, but not @unexisting."
        comment = Factory(:comment, :body => body, :project => @project, :user => @project.user, :target => @task)
        
        comment.mentioned.should == [@user]
        @task.reload.watchers.should include(@user)
      end

      it "should add him to task list" do
        @task_list = Factory(:task_list, :project => @project, :user => @project.user)
        @task_list.watchers.should_not include(@user)

        body = "I would like to add @existing to this, but not @unexisting."
        comment = Factory(:comment, :body => body, :project => @project, :user => @project.user, :target => @task_list)
        
        comment.mentioned.should == [@user]
        @task_list.reload.watchers.should include(@user)
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
    end
    
    it "should be editable and deletable by the creator for only 15 minutes" do
      @comment.can_edit?(@comment.user).should == true
      @comment.can_destroy?(@comment.user).should == true
      
      # backdate to simulate elapsed time
      @comment.created_at -= 16.minutes
      @comment.save!
      
      @comment.can_edit?(@comment.user).should == false
      @comment.can_destroy?(@comment.user).should == false
    end
    
    it "should not be editable by an admin" do
      @comment.can_edit?(@comment.user).should == true
      @comment.can_edit?(@user).should == false
    end
    
    it "should be deletable by an admin forever" do
      @comment.can_destroy?(@user).should == true
      
      # backdate to simulate elapsed time
      @comment.created_at -= 16.minutes
      @comment.save!
      
      @comment.can_destroy?(@user).should == true
    end
    
    it "should not be editable or deletable by another non-admin" do
      @comment.can_edit?(@another_user).should == false
      @comment.can_destroy?(@another_user).should == false
    end
  end

  context "uploads" do
    it "should link existing upload" do
      upload = Factory.create :upload
      comment = Factory.create :comment, :upload_ids => [upload.id.to_s],
        :body => 'Here is that cat video I promised'

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
  end
end