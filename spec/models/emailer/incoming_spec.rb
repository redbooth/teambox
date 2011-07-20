require 'spec_helper'

describe Emailer do 
  describe 'incoming emails' do 
    before do
      @owner = Factory.create(:user)
      @fred = Factory.create(:user)
      @janet = Factory.create(:user)
      @project = Factory.create(:project, :user_id => @owner.id)
      @project.add_user(@fred)
      @task = Factory(:task, :user_id => @owner.id, :project_id => @project.id)
      @conversation = Factory(:conversation, :user_id => @owner.id, :project_id => @project.id)
      
      @email_template = Mail.new
      @email_template.from = @owner.email
    end
    
    context 'an email to create a new task' do
      before do
        @email_template.to = "#{@project.permalink}+task@#{Teambox.config.smtp_settings[:domain]}"
        @email_template.subject = "Our new task subject"
        @email_template.body = "Some body stuff"
      end
      
      it "should create a new task from the subject and assign to the sender then add a comment with the body" do
        lambda do
          Emailer.receive(@email_template.to_s)
        end.should change(Task, :count).by(1)
      
        task = Task.first(:order => 'tasks.id DESC')
        task.user.should == @owner
        task.name.should == @email_template.subject
        task.status_name.should == :new
        task.comments.count.should == 1
        comment = task.comments.first
        comment.assigned_id.should be_nil
        comment.status_name.should == :new
      end
      
      it "should not create a new task if the subject is blank and the body is blank" do
        @email_template.subject = ""
        @email_template.body = ""
        
        lambda do
          lambda do
            Emailer.receive(@email_template.to_s)
          end.should raise_error
        end.should change(Task, :count).by(0)
      end

     it "should set the truncated body as the task name if there is no subject" do
        @email_template.subject = ""
        @email_template.body = "b" * 500

        lambda do
          Emailer.receive(@email_template.to_s)
        end.should change(Task, :count).by(1)

        task = Task.order('id desc').first
        task.name.should == @email_template.body.to_s[0,252] + "..."
        task.status_name.should == :new
      end

     it "should strip any html tags from the body" do
        @email_template.subject = ""
        @email_template.body = "<b>Bold</b> no more!  <a href='more.html'>See more here</a>..."

        lambda do
          Emailer.receive(@email_template.to_s)
        end.should change(Task, :count).by(1)

        task = Task.order('id desc').first
        task.name.should == "Bold no more!  See more here..."
        task.status_name.should == :new
      end

     it "should strip any html tags from the body" do
        @email_template.subject = ""
        @email_template.body = <<-EMAIL
          Get things done:
          <ul>
           <li>Cook</li>
           <li>Clean</li>
           <li>Play</li>
          </ul>
          On 19 August 2010 13:48, User <proj+conversation+22245@app.teambox.com<proj%2Bconversation%2B22245@app.teambox.com>> wrote:"
          #{Emailer::ANSWER_LINE}
          <div class="email">
          <div class="people">
          John, Rob, Jennifer
          </div>
          <div class="message">
          This message is supposed to shrink with the browser.
          </div>
          <div class="date">
          4:15 pm 12/05/07
          </div>
          </div>
        EMAIL

        lambda do
          Emailer.receive(@email_template.to_s)
        end.should change(Task, :count).by(1)

        task = Task.first(:order => 'tasks.id DESC')
        task.name.should == "Get things done:\n          \n           Cook\n           Clean\n           Play"
        task.status_name.should == :new
      end



      it "should add the Inbox list if it exists" do
        list = @project.task_lists.create(:user => @owner, :name => 'Inbox')
        
        lambda do
          Emailer.receive(@email_template.to_s)
        end.should change(Task, :count).by(1)
      
        task = Task.first(:order => 'tasks.id DESC')
        task.task_list.should == list
      end
    
      it "should create the Inbox list if it does not exist" do
        lambda do
          lambda do
            Emailer.receive(@email_template.to_s)
          end.should change(Task, :count).by(1)
        end.should change(TaskList, :count).by(1)
        
        task_list = TaskList.find_by_name('Inbox')
        task = Task.first(:order => 'tasks.id DESC')
        task.task_list.should == task_list
      end
      
      it "should assign the task to fred with #fred" do |variable|
        @email_template.body = "##{@fred.login}\nWe did some stuff"
        Emailer.receive(@email_template.to_s)
        
        task = Task.first(:order => 'tasks.id DESC')
        task.assigned.user.id.should == @fred.id
        comment = task.comments.last
        comment.assigned.user.id.should == @fred.id
        comment.status.should == Task::STATUSES[:open]
        comment.previous_assigned_id.should == nil
        comment.previous_status.should == Task::STATUSES[:new]
      end
      
      it "should assign the given task status when given a status" do
        @email_template.body = "#hold\nWe did some stuff"
        Emailer.receive(@email_template.to_s)
        
        task = Task.first(:order => 'tasks.id DESC')
        task.assigned.should be_nil
        comment = task.comments.last
        comment.assigned.should be_nil
        comment.status_name.should == :hold
        comment.previous_assigned_id.should == nil
        comment.previous_status.should == Task::STATUSES[:new]
      end
    end

    it "should not assign or change the status of the task with no action" do
      @email_template.to = "#{@project.permalink}+task+#{@task.id}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.body = "#\nWe did some stuff"
      Emailer.receive(@email_template.to_s)
      
      @task.reload
      comment = @task.comments.last
      @task.assigned?.should be_false
      @task.status_name.should == :new
      comment.assigned_id.should be_nil
      comment.status.should be_nil
    end
    
    it "should assign the task to fred with #fred" do
      @email_template.to = "#{@project.permalink}+task+#{@task.id}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.body = "##{@fred.login}\nWe did some stuff"
      Emailer.receive(@email_template.to_s)
      
      @task.reload
      comment = @task.comments.last
      @task.assigned.user.id.should == @fred.id
      @task.status.should == Task::STATUSES[:open]
      comment.assigned.user.id.should == @fred.id
      comment.status.should == Task::STATUSES[:open]
      comment.previous_assigned_id.should == nil
      comment.previous_status.should == Task::STATUSES[:new]
    end
    
    it "should not assign the task to janet with #janet" do
      @email_template.to = "#{@project.permalink}+task+#{@task.id}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.body = "##{@janet.login}\nWe did some stuff"
      Emailer.receive(@email_template.to_s)
      
      @task.reload
      comment = @task.comments.last
      @task.assigned_id.should_not == @janet.id
    end
    
    it "should resolve the task with #resolve or #resolved" do
      @email_template.to = "#{@project.permalink}+task+#{@task.id}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.body = "#resolve\nWe did some stuff"
      Emailer.receive(@email_template.to_s)
      
      @task.reload
      comment = @task.comments.last
      @task.status_name.should == :resolved
      comment.status.should == Task::STATUSES[:resolved]
      comment.previous_status.should == 0
    end
    
    it "should hold the task with #hold" do
      @email_template.to = "#{@project.permalink}+task+#{@task.id}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.body = "#hold\nWe did some stuff"
      Emailer.receive(@email_template.to_s)
      
      @task.reload
      comment = @task.comments.last
      @task.status.should == Task::STATUSES[:hold]
      comment.status.should == Task::STATUSES[:hold]
      comment.previous_status.should == Task::STATUSES[:new]
    end
    
    it "should reject the task with #reject" do
      @email_template.to = "#{@project.permalink}+task+#{@task.id}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.body = "#reject\nWe did some stuff"
      Emailer.receive(@email_template.to_s)
      
      @task.reload
      comment = @task.comments.last
      @task.status.should == Task::STATUSES[:rejected]
      comment.status.should == Task::STATUSES[:rejected]
      comment.previous_status.should == Task::STATUSES[:new]
    end

    it "should still parse with newlines and spaces in front" do
      @email_template.to = "#{@project.permalink}+task+#{@task.id}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.body = "\n\n  \n\n \n\n#hold\nPeople like newlines too. So lets implement that!"
      Emailer.receive(@email_template.to_s)
      
      @task.reload
      comment = @task.comments.last
      @task.status.should == Task::STATUSES[:hold]
      comment.status.should == Task::STATUSES[:hold]
      comment.previous_status.should == Task::STATUSES[:new]
    end
    
    it "should extract actions from emails" do
      @email_template.to = "#{@project.permalink}+task+#{@task.id}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.body = "\n\n  \n\n \n\n#hold\nPeople like newlines too. So lets implement that!"
      Emailer.receive(@email_template.to_s)
      
      @task.reload
      comment = @task.comments.last
      comment.body.should == "People like newlines too. So lets implement that!"
    end
    
    it "should post a comment to a project if no subject is given" do
      @email_template.to = "#{@project.permalink}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.body = "Yes i agree completely!"
      Emailer.receive(@email_template.to_s)
      
      @project.conversations(true).first.simple.should == true
      comment = @project.comments(true).first
      comment.body.should == "Yes i agree completely!"
    end

    it "should post a comment to a project if there's a subject" do
      @email_template.to = "#{@project.permalink}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.subject = "Wat do I do?"
      @email_template.body = "the problem is solution"
      Emailer.receive(@email_template.to_s)

      conversation = @project.conversations(true).first
      conversation.simple.should == false
      conversation.name.should == "Wat do I do?"
      comment = @project.comments(true).first
      comment.body.should == "the problem is solution"
    end

    it "should post a comment to a conversation" do
      @email_template.to = "#{@project.permalink}+conversation+#{@conversation.id}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.body = "I am outraged!"
      
      lambda {
        Emailer.receive(@email_template.to_s)
      }.should change(Comment, :count).by(1)
      
      comment = @conversation.comments(true).first(:order => 'comments.id DESC')
      comment.body.should == "I am outraged!"
    end

    it "should create a conversation with the subject as title and the body as comment" do
      @email_template.to = "#{@project.permalink}+conversation@#{Teambox.config.smtp_settings[:domain]}"
      accepted_prefixes = %w(Re: RE: Fwd: FWD:) << ""
      accepted_prefixes.each_with_index do |prefix, i|
        @email_template.subject = "#{prefix} This feature wasn't tested grrrr... #{i}"
        @email_template.body = "But I'm fixing it right now! And refactoring the Regexp too!\n\nI'm using #{prefix} on the subject"
        Emailer.receive(@email_template.to_s)
        conv = @project.conversations.first
        conv.name.should == "This feature wasn't tested grrrr... #{i}"
        conv.comments.first.body.should == "But I'm fixing it right now! And refactoring the Regexp too!\n\nI'm using #{prefix} on the subject"
        conv.user.should == @owner
      end
    end
    
    context "should raise an error when" do
      before do
        @email_template.to = "#{@project.permalink}+task+#{@task.id}@#{Teambox.config.smtp_settings[:domain]}"
        @email_template.body = "#\nWe did some stuff"
      end
      
      it "the email sender is not recognised" do
        @email_template.from = "random.sender@example.com"
        
        lambda do
          Emailer.receive(@email_template.to_s)
        end.should raise_error(Emailer::Incoming::UserNotFoundError) { |e|
          e.mail.from.should == @email_template.from
        }
      end
      
      it "the specified project does not exist" do
        @email_template.to = "random_project+tasks@#{Teambox.config.smtp_settings[:domain]}"
        
        lambda do
          Emailer.receive(@email_template.to_s)
        end.should raise_error Emailer::Incoming::ProjectNotFoundError
      end
      
      it "is not part of the specified project" do
        @email_template.from = @janet.email
        
        lambda do
          Emailer.receive(@email_template.to_s)
        end.should raise_error Emailer::Incoming::NotProjectMemberError
      end
      
      it "the specified conversation does not exist" do
        @email_template.to = "#{@project.permalink}+conversation+#{rand(1000) + 1000}@#{Teambox.config.smtp_settings[:domain]}"
        
        lambda do
          Emailer.receive(@email_template.to_s)
        end.should raise_error Emailer::Incoming::TargetNotFoundError
      end
      
      it "the specified task does not exist" do
        @email_template.to = "#{@project.permalink}+task+#{rand(1000) + 1000}@#{Teambox.config.smtp_settings[:domain]}"
        
        lambda do
          Emailer.receive(@email_template.to_s)
        end.should raise_error Emailer::Incoming::TargetNotFoundError
      end
      
    end
  end
end
