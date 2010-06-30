require File.dirname(__FILE__) + '/../../spec_helper'
require_dependency 'emailer/incoming'

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
      
      @email_template = TMail::Mail.new
      @email_template.from = @owner.email
    end

    it "should not assign or change the status of the task with no action" do
      @email_template.to = "#{@project.permalink}+task+#{@task.id}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.body = "#\nWe did some stuff"
      Emailer.receive(@email_template.to_s)
      
      @task.reload
      comment = @task.comments.last
      @task.assigned_id.should == nil
      @task.status.should == Task::STATUSES[:new]
      comment.assigned_id.should == nil
      comment.status.should == Task::STATUSES[:new]
      comment.previous_assigned_id.should == nil
      comment.previous_status.should == Task::STATUSES[:new]
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
      @task.status.should == Task::STATUSES[:resolved]
      comment.status.should == Task::STATUSES[:resolved]
      comment.previous_status.should == 0
    end
    
    it "should resolve the task with #resolve" do
      @email_template.to = "#{@project.permalink}+task+#{@task.id}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.body = "#resolve\nWe did some stuff"
      Emailer.receive(@email_template.to_s)
      
      @task.reload
      comment = @task.comments.last
      @task.status.should == Task::STATUSES[:resolved]
      comment.status.should == Task::STATUSES[:resolved]
      comment.previous_status.should == Task::STATUSES[:new]
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
    
    it "should post a comment to a project" do
      @email_template.to = "#{@project.permalink}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.body = "Yes i agree completely!"
      Emailer.receive(@email_template.to_s)
      
      comment = @project.comments(true).first
      comment.body.should == "Yes i agree completely!"
    end
    
    it "should post a comment to a conversation" do
      @email_template.to = "#{@project.permalink}+conversation+#{@conversation.id}@#{Teambox.config.smtp_settings[:domain]}"
      @email_template.body = "I am outraged!"
      Emailer.receive(@email_template.to_s)
      
      comment = @conversation.comments(true).last
      comment.body.should == "I am outraged!"
    end
  end
end