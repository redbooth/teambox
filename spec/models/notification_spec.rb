require 'spec_helper'

describe Notification do 
  describe 'digest' do
    before do
      @charles = Factory.create(:user, :notify_pages => true)
      @pablo = Factory.create(:user, :notify_pages => true)
      @james = Factory.create(:user, :notify_pages => true)
      @jordi = Factory.create(:user, :notify_pages => true)
      @saimon  = Factory.create(:user, :notify_pages => true)

      @project = Factory.create(:project)
      
      [@charles, @pablo, @james, @jordi, @saimon].each do |user|
        @project.add_user(user)
      end

      @task = Factory(:task, :user => @charles, :project => @project)
      @conversation = Factory(:conversation, :user => @charles, :project => @project)
      @page = Factory(:page, :user => @charles, :project => @project)

      @conversation.add_watchers([@charles, @pablo, @james, @saimon])
      @task.add_watchers([@charles, @pablo, @james, @saimon])
      @page.add_watchers([@charles, @pablo, @james, @saimon])
    end
    
    context 'Notify watchers on conversation, task or page' do
      it 'should create notification for conversation watchers, except commenter' do
        @comment = Factory(:comment, :target => @conversation, :user => @charles)
        Notification.where(:comment_id => @comment.id).count.should == 3
      end

      it 'should create notification for task watchers, except commenter' do
        @comment = Factory(:comment, :target => @task, :user => @charles)
        Notification.where(:comment_id => @comment.id).count.should == 3
      end

      it 'should create notification for page watchers on update, except commenter' do
        @note = @page.build_note({:name => 'List'}).tap do |n|
          n.updated_by = @charles
          n.save
        end

        Notification.where(:target_type => 'Activity').count.should == 3
      end
    end

    context 'should send digest at the correct time, and only once' do
      before do
        @midnight = Time.now.utc.at_midnight + 1.week
        @tuesday   = @midnight.monday + 1.day

        @charles.update_attributes({:digest_delivery_hour => 9, :time_zone => 'Eastern Time (US & Canada)', :first_day_of_week => 'sunday', :instant_notification_on_mention => false})
        @charles.people.first.update_attributes(:digest => 1)
        
        @james.update_attributes({:digest_delivery_hour => 10, :time_zone => 'London', :first_day_of_week => 'sunday', :instant_notification_on_mention => false})
        @james.people.first.update_attributes(:digest => 1)
        
        @pablo.update_attributes({:digest_delivery_hour => 8, :time_zone => 'Madrid', :first_day_of_week => 'sunday', :instant_notification_on_mention => true})
        @pablo.people.first.update_attributes(:digest => 2)
        
        @jordi.update_attributes({:digest_delivery_hour => 22, :time_zone => 'Madrid', :first_day_of_week => 'monday', :instant_notification_on_mention => true})
        @jordi.people.first.update_attributes(:digest => 2)

        @saimon.update_attributes({:digest_delivery_hour => 8, :time_zone => 'Madrid', :first_day_of_week => 'monday', :instant_notification_on_mention => true})
        @saimon.people.first.update_attributes(:digest => 0)

        reset_mailer
      end

      it 'should send daily digest and respect delivery settings' do
        time_is_now(@midnight) do
          Factory(:comment, :target => @conversation, :user => @pablo)
          Factory(:comment, :target => @task, :user => @jordi)
          @page.build_note({:name => 'List'}).tap do |n|
            n.updated_by = @jordi
            n.save
          end


          unread_emails_for(@james.email).size.should == 0
          unread_emails_for(@charles.email).size.should == 0
        end

        time_is_now(@midnight + 11.hour) do
          Person.send_all_digest
          # because '09:00:00' is not between '19:00:00' to '07:00:00'
          unread_emails_for(@charles.email).size.should == 0
          # because '10:00:00' is between '00:00:00' and '11:00:00'
          unread_emails_for(@james.email).size.should == 1
        end
      end

      it 'should send weekly digest and respect delivery settings' do
        time_is_now(@tuesday) do
          Factory(:comment, :target => @conversation, :user => @charles)
          Factory(:comment, :target => @task, :user => @james)


          unread_emails_for(@pablo.email).size.should == 0
          unread_emails_for(@jordi.email).size.should == 0
        end

        time_is_now(@tuesday + 6.day + 9.hour) do
          Person.send_all_digest
          unread_emails_for(@pablo.email).size.should == 1
          unread_emails_for(@jordi.email).size.should == 0
        end
      end

      it 'should mark notification as sent after delivery' do
        time_is_now(@tuesday) do
          Factory(:comment, :target => @conversation, :user => @charles)
          unread_emails_for(@pablo.email).size.should == 0
        end

        time_is_now(@tuesday + 7.day) do
          Person.send_all_digest
          @pablo.notifications.where(:sent => false).count.should == 0
        end
      end

      it 'should not send notification if target comment is deleted' do
        time_is_now(@tuesday) do
          @comment = Factory(:comment, :target => @conversation, :user => @charles)
          unread_emails_for(@pablo.email).size.should == 0
        end

        time_is_now(@tuesday + 7.day) do
          @comment.destroy
          Person.send_all_digest
          unread_emails_for(@pablo.email).size.should == 0
        end
      end

      it 'should not send notification if target is deleted' do
        time_is_now(@tuesday) do
          @comment = Factory(:comment, :target => @conversation, :user => @charles)
          unread_emails_for(@pablo.email).size.should == 0
        end

        time_is_now(@tuesday + 7.day) do
          @conversation.destroy
          Person.send_all_digest
          unread_emails_for(@pablo.email).size.should == 0
        end
      end

      it 'should send notification instantly when a user configure a project to email instantly' do
        Factory(:comment, :target => @conversation, :user => @charles, :body => "Hey @all, have a look at this!")
        unread_emails_for(@saimon.email).size.should == 1
      end

      it 'should send a notification email instantly on mentioned when user account is set to notify on mention' do
        Factory(:comment, :target => @conversation, :user => @charles, :project => @project, :body => "Hey @all, have a look at this conversation!")
        Factory(:comment, :target => @task, :user => @charles, :project => @project, :body => "Hey @all, have a look at this task!")

        unread_emails_for(@jordi.email).size.should == 2
        unread_emails_for(@pablo.email).size.should == 2
        unread_emails_for(@james.email).size.should == 0
        unread_emails_for(@charles.email).size.should == 0
      end

      it 'should skip deleted object' do
        time_is_now(@tuesday) do
          @note = @page.build_note({:name => 'List'}).tap do |n|
            n.updated_by = @charles
            n.save
          end

          @deleted_task = Factory(:task, :user_id => @charles.id, :project_id => @project.id)
          @deleted_conversation = Factory(:conversation, :user_id => @charles.id, :project_id => @project.id)

          @first_conversation_comment = Factory(:comment, :target => @conversation, :user => @charles,
            :project => @project, :body => "Comment on conversation")
          @second_task_comment        = Factory(:comment, :target => @task, :user => @charles,
            :project => @project, :body => "Comment on task")

          @deleted_comment_on_conversation = Factory(:comment, :target => @conversation, :user => @charles,
            :project => @project, :body => "Deleted comment on conversation")
          @deleted_comment_on_task         = Factory(:comment, :target => @task, :user => @charles,
            :project => @project, :body => "Deleted comment on task")

          @comment_on_deleted_conversation = Factory(:comment, :target => @deleted_conversation, :user => @charles,
            :project => @project, :body => "Comment on deleted conversation")
          @comment_on_deleted_task         = Factory(:comment, :target => @deleted_task, :user => @charles,
            :project => @project, :body => "Comment on deleted task")
        end

        time_is_now(@tuesday + 10.days) do
          @page.destroy
          @deleted_comment_on_conversation.destroy
          @deleted_comment_on_task.destroy
          @deleted_task.destroy
          @deleted_conversation.destroy

          Person.send_all_digest

          unread_emails_for(@pablo.email).size.should == 1

          email_body = open_email(@pablo.email).html_part.body

          email_body.should =~ Regexp.new("Comment on conversation")
          email_body.should =~ Regexp.new("Comment on task")

          email_body.should_not =~ Regexp.new("Deleted comment on conversation")
          email_body.should_not =~ Regexp.new("Deleted comment on task")

          email_body.should_not =~ Regexp.new("Comment on deleted conversation")
          email_body.should_not =~ Regexp.new("Comment on deleted task")
        end

      end
    end

    def time_is_now(time)
      Time.stub(:now).and_return(time)
      yield
      Time.unstub(:now)
    end

  end
end
