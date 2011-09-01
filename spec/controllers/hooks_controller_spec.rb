require 'spec_helper'

describe HooksController do
  it "should route to hooks controller" do
    { :post => '/hooks/email' }.should route_to(:action => "create", 
      :hook_name => "email",
      :controller => "hooks")
  end

  it "should route to hooks controller scoped under project" do
    { :post => '/projects/12/hooks/pivotal' }.should route_to(:action => "create", 
      :hook_name => "pivotal",
      :controller => "hooks",
      :project_id => "12")
  end
  
  it "should route to hooks controller scoped under project" do
    { :post => '/hooks/github'}.should route_to(:action => "create",
      :hook_name => "github",
      :controller => "hooks")
  end

  describe "#create" do
    before do
      @project = Factory(:project)
    end

    describe "emails" do
      it "should parse incoming emails to new conversation" do
        post_email_hook  @project.permalink,
          'Random latin text',
          'Lorem ipsum dolor sit amet, ...',
          false

        response.should be_success
        conversation = @project.conversations.last(:order => 'id asc')
        conversation.name.should == 'Random latin text'
        conversation.comments.last.body.should == 'Lorem ipsum dolor sit amet, ...'
        conversation.comments.last.uploads.count.should == 0
      end

      it "should parse incoming emails with attachments to new conversation" do
        post_email_hook  @project.permalink,
          'Hey, check this awesome file!',
          'Lorem ipsum dolor sit amet, ...'

        response.should be_success
        conversation = @project.conversations.last(:order => 'id asc')
        conversation.name.should == 'Hey, check this awesome file!'
        conversation.comments.last.body.should == 'Lorem ipsum dolor sit amet, ...'
        conversation.comments.last.uploads.count.should == 2
        conversation.comments.last.uploads.first.asset_file_name.should == 'tb-space.jpg'
      end
      
      it "handles encoded headers" do
        post :create, default_params(
          :to => "=?ISO-8859-1?Q?Moo?= <#{@project.permalink}@#{Teambox.config.smtp_settings[:domain]}>\n",
          :text => "Hello there"
        )
        
        response.should be_success
        comment = @project.conversations.last(:order => 'id asc').comments.first
        comment.body.should == "Hello there"
      end
      
      it "handles encoded body" do
        post :create, default_params(
          :text => "\350\346\276\271\360",
          :charsets => '{"text":"iso-8859-2"}'
        )
        post :create, default_params(
          :text => "\351\361 \370\374\347 \337\360",
          :charsets => '{"text":"iso-8859-1"}'
        )
        
        comments = Comment.all(:limit => 2, :order => 'id desc')
        comments.first.body.should == "éñ øüç ßð"
        comments.second.body.should == "čćžšđ"
      end
      
      it "ignores email with missing info" do
        post :create, default_params(:from => '')
        
        response.should be_success
        response.body.should == "Invalid From field"
      end
      
      it "ignores email without plaintext part" do
        post :create, default_params(:text => nil)
        
        response.should be_success
        response.body.should == "Invalid mail body"
      end
      
      it "ignores email with invalid 'to' address" do
        post :create, default_params(:to => 'me@moo.com')
        
        response.should be_success
        response.body.should == "Invalid To fields"
      end

      it "should parse incoming emails with attachments to conversation answers" do
        @task = Factory(:task, :project => @project)
        
        post_email_hook "#{@project.permalink}+task+#{@task.id}",
          '',
          'I would say something about this task'

        comment = @task.comments(true).last
        comment.body.should == 'I would say something about this task'
        comment.uploads.count.should == 2
      end

      it "should parse incoming emails with attachments to task answers" do
        @conversation = Factory(:conversation, :project => @project)
        
        post_email_hook "#{@project.permalink}+conversation+#{@conversation.id}",
          '',
          'I would say something about this conversation'

        comment = @conversation.comments(true).except(:order).last(:order => 'ID ASC')
        comment.body.should == 'I would say something about this conversation'
        comment.uploads.count.should == 2
      end
      
      context "the bounce system" do
        before do
          @options = post_options("#{@project.permalink}+task", 'Some subject', 'I would say something about this task')
        end
        
        it "should raise (200 for sendgrid) and create a bounce message if an unknown user posts to a project" do
          options = @options.merge!(:from => 'random_person@teambox.com')
          check_bounce_message(options) do
            post :create, options
          end
          response.response_code.should == 200
        end
        
        it "should raise (200 for sendgrid) and create a bounce message if a user does not belong to a project" do
          options = @options.merge!(:from => Factory(:user).email)
          check_bounce_message(options) do
            post :create, options
          end
          response.response_code.should == 200
        end
      
        it "should raise (200 for sendgrid) and create a bounce message if a project is not found" do
          options = @options.merge!(:to => "#{@project.permalink}+task+#{rand(1000) + 1000}@#{Teambox.config.smtp_settings[:domain]}")
          check_bounce_message(options) do
            post :create, options
          end
          response.response_code.should == 200
        end
        
        it "should raise (200 for sendgrid) and create a bounce message if a conversation is not found" do
          options = @options.merge(:to => "#{@project.permalink}+conversation+#{rand(1000) + 1000}@#{Teambox.config.smtp_settings[:domain]}")
          check_bounce_message(options) do
            post :create, options
          end
          response.response_code.should == 200
        end
        
        it "should raise (200 for sendgrid) and create a bounce message for invalid target" do
          address = "#{@project.permalink}+tasknuevo@#{Teambox.config.smtp_settings[:domain]}"
          options = @options.merge(:to => address)
          
          check_bounce_message(options) do
            post :create, options
          end
          response.response_code.should == 200
        end
      end
      
      def check_bounce_message(options, &block)
        Emailer.should_receive(:send_with_language).with(
          :bounce_message, :en, kind_of(Array), kind_of(String)
        ).once
        
        lambda do
          yield
        end.should change(EmailBounce, :count).by(1)
      end
      
      def post_email_hook(to, subject, body, attachments = true)
        post :create, post_options(to, subject, body, attachments)
      end
      
      def post_options(to, subject, body, attachments = true)
        {
          :hook_name => 'email',
          :method => :post,
          :from => @project.user.email,
          :to => "#{to}@#{Teambox.config.smtp_settings[:domain]}",
          :text => body,
          :subject => subject,
          :attachments => attachments ? '2' : nil,
          :attachment1 => upload_file("#{Rails.root}/spec/fixtures/tb-space.jpg", 'image/jpg'),
          :attachment2 => upload_file("#{Rails.root}/spec/fixtures/teamboxdump.json", 'text/plain')
        }
      end
      
      def default_params(more = {})
        { :hook_name => 'email',
          :from => @project.user.email,
          :to => "#{@project.permalink}@#{Teambox.config.smtp_settings[:domain]}",
          :text => "Nothing to say",
          :subject => "Just testing"
        }.update(more)
      end
    end
    
    describe "Pivotal Tracker" do
      before do
        @payload_v2 = {"activity"=>
            {"author"=>"James Kirk",
            "project_id"=>26,
            "occurred_at"=>Time.parse("Mon Dec 14 22:12:09 UTC 2009"),
            "id"=>1031,
            "version"=>175,
            "description"=>'James Kirk accepted "More power to shields"',
            "event_type"=>"story_update",
            "stories"=>
              {"story"=>
                {"current_state"=>"accepted",
                "name"=>"More power to shields",
                "accepted_at"=>Time.parse("Mon Dec 14 22:12:09 UTC 2009"),
                "url"=>"https:///projects/26/stories/109",
                "id"=>109}}}}
        
        @payload_v3 = {"activity"=>
            {"author"=>"James Kirk",
            "project_id"=>26,
            "occurred_at"=>Time.parse("Mon Dec 14 22:12:09 UTC 2009"),
            "id"=>1031,
            "version"=>175,
            "description"=>'James Kirk accepted "More power to shields"',
            "event_type"=>"story_update",
            "stories"=> [
              {
                "current_state"=>"delivered",
                "url"=>"https:///projects/26/stories/109",
                "id"=>109
              }
            ]
          }}
          
        @payload_v3_new = {"activity"=>
            {"author"=>"James Kirk",
            "project_id"=>26,
            "occurred_at"=>Time.parse("Mon Dec 14 22:12:09 UTC 2009"),
            "id"=>1031,
            "version"=>175,
            "description"=>'James Kirk created "More power to shields"',
            "event_type"=>"story_update",
            "stories"=> [
              {
                "name" => "More power to shields",
                "current_state"=>"unscheduled",
                "url"=>"https:///projects/26/stories/109",
                "id"=>109
              }
            ]
          }}
      end
      
      def post(payload = @payload_v2, hook = 'pivotal')
        super :create, payload.merge(:hook_name => hook, :project_id => @project.id)
      end
      
      describe "V2" do
        it "should create a new task list" do
          post
          response.should be_success
        
          task_list = @project.task_lists.first
          task_list.name.should == "Pivotal Tracker"
        
          task = task_list.tasks.first
          task.name.should == "More power to shields [PT109]"
          task.status_name.should == :resolved
          task.comments.first.body.should == "James Kirk marked the task as accepted on #PT"
        end
      
        it "should ignore unknown task statuses" do
          @payload_v2['activity']['stories']['story']['current_state'] = "smokin'!"
          post
          task = Task.first
          task.status_name.should == :new
        end
      end
    
      describe "V3" do
        it "should raise an error when sending to V3 in this format" do
          post(@payload_v2, 'pivotal_v3')
          response.status.should == 400
          response.body.should == "Tracker appears to be in old format"
        end
      
        it "should create a new task list" do
          post(@payload_v3_new, 'pivotal_v3')
          response.should be_success, response.body
        
          task_list = @project.task_lists.first
          task_list.name.should == "Pivotal Tracker"
        
          task = task_list.tasks.first
          task.name.should == "More power to shields [PT109]"
          task.status_name.should == :new
        end
        
        it "should update a task if it exists" do
          post(@payload_v3_new, 'pivotal_v3')
          response.should be_success, response.body
          
          task_list = @project.task_lists.first
          task_list.name.should == "Pivotal Tracker"
          task = task_list.tasks.first
          task.name.should == "More power to shields [PT109]"
          
          sleep(2)
          
          lambda do
            post(@payload_v3, 'pivotal_v3')
            response.should be_success, response.inspect
        
            task_list = @project.task_lists.first.reload
            task_list.name.should == "Pivotal Tracker"
        
            task = task_list.tasks.first.reload
            task.name.should == "More power to shields [PT109]"
            task.status_name.should == :hold
          end.should change(Task, :count).by(0)
        end
        
        it "should create a task on an update if it does not exist" do
          post(@payload_v3, 'pivotal_v3')
          response.should be_success, response.body
        
          task_list = @project.task_lists.first
          task_list.name.should == "Pivotal Tracker"
        
          task = task_list.tasks.first
          task.name.should == "James Kirk accepted \"More power to shields\" [PT109]"
          task.status_name.should == :hold
        end
      
        it "should ignore unknown task statuses" do
          @payload_v3['activity']['stories'].first['current_state'] = "smokin'!"
          post(@payload_v3, 'pivotal_v3')
          task = Task.first
          task.status_name.should == :new
        end
      end
    end
    
    describe "GitHub" do
      
      before do

        @mislav = Factory(:mislav)
        @chris = Factory(:user, {:first_name => "Chris", :last_name => "Wanstrath"})
        @frank = Factory(:user, {:email => "frank@teambox.com"})

        @project.add_user @chris
        @project.add_user @mislav
        @project.add_user @frank

        @task_list = Factory(:task_list, :project => @project, :user => @mislav)

        @task = Factory(:task, {:project => @project, :user => @mislav, :task_list => @task_list, :name => "Do something Chris"})
        @task.assign_to @chris

        @other_task = Factory(:task, {:project => @project, :user => @chris, :task_list => @task_list, :name => "Do something Mislav"})
        @other_task.assign_to @mislav

        @payload = <<-JSON
          {
            "before": "5aef35982fb2d34e9d9d4502f6ede1072793222d",
            "after": "de8251ff97ee194a289832576287d6f8ad74e3d0",
            "ref": "refs/heads/master",
            "pusher": {"email":"frank@teambox.com","name":"frank"},
            "compare": "https://github.com/teambox/teambox/compare/41a212e^...hju8251",
            "repository": {
              "url": "http://github.com/defunkt/github",
              "name": "github",
              "description": "You're lookin' at it.",
              "watchers": 5, "forks": 2, "private": 1,
              "owner": { "email": "chris@ozmm.org", "name": "defunkt" }
            },
            "commits": [
              {
                "id": "41a212ee83ca127e3c8cf465891ab7216a705f59",
                "url": "http://github.com/defunkt/github/commit/41a212ee83ca127e3c8cf465891ab7216a705f59",
                "author": { "email": "chris@ozmm.org", "name": "Chris Wanstrath" },
                "message": "Check this file, task [#{@task.id}]",
                "timestamp": "2008-02-15T14:57:17-08:00",
                "added": ["filepath.rb"]
              },
              {
                "id": "de8251ff97ee194a289832576287d6f8ad74e3d0",
                "url": "http://github.com/defunkt/github/commit/de8251ff97ee194a289832576287d6f8ad74e3d0",
                "author": { "email": "#{@mislav.email}", "name": "#{@mislav.name}" },
                "message": "Closing for task[close-#{@task.id}]",
                "timestamp": "2008-02-15T14:36:34-08:00"
              },
              {
                "id": "7gh251ff97ee194a289832576287d6f8ad74uiui6",
                "url": "http://github.com/defunkt/github/commit/7gh251ff97ee194a289832576287d6f8ad74uiui6",
                "author": { "email": "chris@ozmm.org", "name": "Chris Wanstrath" },
                "message": "Not existing task [9999]",
                "timestamp": "2008-02-15T16:39:34-08:00"
              },
              {
                "id": "hj6251i97ee19tyr28ig676F76287d6f8ag5r5Y5",
                "url": "http://github.com/defunkt/github/commit/hj6251i97ee19tyr28ig676F76287d6f8ag5r5Y5",
                "author": { "email": "chris@ozmm.org", "name": "Chris Wanstrath" },
                "message": "Forgot task id so it should appear under new conversation in old style",
                "timestamp": "2008-02-16T17:07:12-08:00"
              },
              {
                "id": "fgh251i97ee19tyr28ig676F76287d6f8ag5rghy",
                "url": "http://github.com/defunkt/github/commit/fgh251i97ee19tyr28ig676F76287d6f8ag5rghy",
                "author": { "email": "#{@mislav.email}", "name": "#{@mislav.name}" },
                "message": "Here forgot task id as well",
                "timestamp": "2008-02-16T17:09:12-08:00"
              },
              {
                "id": "hju8251ff97ee194a289832576287d6f89ui7978h",
                "url": "http://github.com/defunkt/github/commit/hju8251ff97ee194a289832576287d6f89ui7978h",
                "author": { "email": "#{@mislav.email}", "name": "#{@mislav.name}" },
                "message": "Commit for different task [#{@other_task.id}]",
                "timestamp": "2008-02-16T12:66:37-08:00"
              }
            ]
          }
        JSON
      end

      it "creates both new conversation and tasks comments when param conversations passed" do

        lambda do
          post :create, :payload => @payload, :hook_name => 'github', :project_id => @project.id, :conversations => true
        end.should change(Conversation, :count).by(1)

        @task.comments.count.should eql(1)
        @other_task.comments.count.should eql(1)
        
        conversation = @project.conversations.last
        conversation.user.should == @mislav
        conversation.should be_simple
        conversation.name.should eql "New code on master branch"
        expected = (<<-HTML).strip
Posted on Github: <a href=\"http://github.com/defunkt/github/tree/master\">github/refs/heads/master</a> <a href=\"https://github.com/teambox/teambox/compare/41a212e^...hju8251\">(compare)</a>

Chris Wanstrath - <a href=\"http://github.com/defunkt/github/commit/hj6251i97ee19tyr28ig676F76287d6f8ag5r5Y5\">Forgot task id so it should appear under new conversation in old style</a>

Mislav Marohnić - <a href=\"http://github.com/defunkt/github/commit/fgh251i97ee19tyr28ig676F76287d6f8ag5rghy\">Here forgot task id as well</a>
        HTML

        conversation.comments.first.body.strip.should == expected.strip

      end

      it "accepts hooks without commits" do

        @other_task = Factory(:task, {:project => @project, :user => @chris, :task_list => @task_list, :name => "Do something Mislav"})
        @other_task.assign_to @mislav

        payload_wc = <<-JSON
            {
            "before": "5aef35982fb2d34e9d9d4502f6ede1072793222d",
            "repository": {
              "url": "http://github.com/defunkt/github",
              "name": "github",
              "description": "You're lookin' at it.",
              "watchers": 5, "forks": 2, "private": 1,
              "owner": { "email": "chris@ozmm.org", "name": "defunkt" }
            },
            "commits": [],
            "after": "de8251ff97ee194a289832576287d6f8ad74e3d0",
            "ref": "refs/heads/master"
          }
        JSON
        
        lambda do
          post :create, :payload => payload_wc, :hook_name => 'github', :project_id => @project.id, :conversations => true
        end.should change(Conversation, :count).by(1)

        conversation = @project.conversations.last
        conversation.user.should_not == nil
        conversation.should be_simple
        conversation.name.should eql "New code on master branch"

        expected = (<<-HTML).strip
Posted on Github: <a href=\"http://github.com/defunkt/github/tree/master\">github/refs/heads/master</a>
        HTML

        conversation.comments.first.body.strip.should == expected.strip

      end

      it "post only task comments as default behaviour" do

        lambda do
          post :create, :payload => @payload, :hook_name => 'github', :project_id => @project.id
        end.should_not change(Conversation, :count)
        
        @task.reload
        @other_task.reload

        first_comment = @task.recent_comments.first

        first_comment.user.should == @frank
        first_comment.target.should == @task

        second_comment = @other_task.recent_comments.first

        second_comment.user.should == @frank
        second_comment.target.should == @other_task

        expected_first = (<<-HTML).strip
         Posted on Github: <a href=\"http://github.com/defunkt/github/tree/master\">github/refs/heads/master</a> <a href=\"https://github.com/teambox/teambox/compare/41a212e^...hju8251\">(compare)</a>

Chris Wanstrath - <a href=\"http://github.com/defunkt/github/commit/41a212ee83ca127e3c8cf465891ab7216a705f59\">Check this file, task</a>\n
Mislav Marohnić - <a href=\"http://github.com/defunkt/github/commit/de8251ff97ee194a289832576287d6f8ad74e3d0\">Closing for task</a>
        HTML

        first_comment.body.strip.should == expected_first.strip

        expected_second = (<<-HTML).strip
         Posted on Github: <a href=\"http://github.com/defunkt/github/tree/master\">github/refs/heads/master</a> <a href=\"https://github.com/teambox/teambox/compare/41a212e^...hju8251\">(compare)</a>

Mislav Marohnić - <a href=\"http://github.com/defunkt/github/commit/hju8251ff97ee194a289832576287d6f89ui7978h\">Commit for different task</a>
        HTML

        second_comment.body.strip.should == expected_second.strip

        @task.status_name.should equal :resolved
        @other_task.status_name.should_not equal :resolved

        Comment.find_by_body('Forgot_task_id').should be nil
        Comment.find_by_body('Not existing task [9999]').should be nil

      end

    end
  end
end
