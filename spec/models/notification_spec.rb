require 'spec_helper'

describe Notification do 
  describe 'Notification and digest' do 
    before do
      @charles = Factory.create(:user)
      @pablo = Factory.create(:user)
      @james = Factory.create(:user)
      @jordi = Factory.create(:user)
      @saimon  = Factory.create(:user)

      @project = Factory.create(:project)
      
      [@charles, @pablo, @james, @jordi, @saimon].each do |user|
        Factory(:person, :user => user, :project => @project)
      end

      @task = Factory(:task, :user_id => @charles.id, :project_id => @project.id)
      @conversation = Factory(:conversation, :user_id => @charles.id, :project_id => @project.id)

      @conversation.add_watchers([@charles, @pablo, @james, @saimon])
      @task.add_watchers([@charles, @pablo, @james, @saimon])
    end
    
    context 'Update on conversation or task' do
      it 'should create notification for conversation watchers, except commenter' do
        @comments = Factory(:comment, :target => @conversation, :user => @charles)
        Notification.where(:comment_id => @comments.id).count.should == 3
      end

      it 'should create notification for task watchers, except commenter' do
        @comments = Factory(:comment, :target => @task, :user => @charles)
        Notification.where(:comment_id => @comments.id).count.should == 3
      end
    end

    context 'should send Digest correct time, and only once' do
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
          @comments = Factory(:comment, :target => @conversation, :user => @pablo)
          @comments = Factory(:comment, :target => @task, :user => @jordi)


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
          @comments = Factory(:comment, :target => @conversation, :user => @charles)
          @comments = Factory(:comment, :target => @task, :user => @james)


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
          @comments = Factory(:comment, :target => @conversation, :user => @charles)

          unread_emails_for(@pablo.email).size.should == 0
        end

        time_is_now(@tuesday + 7.day) do
          Person.send_all_digest
          unread_emails_for(@pablo.email).size.should == 1
        end
      end

      it 'should send notification instantly when a user configure a project to email instantly' do
        @comments = Factory(:comment, :target => @conversation, :user => @charles, :body => "Hey @all, have a look at this!")
        unread_emails_for(@saimon.email).size.should == 1
      end

      it 'should send a notification email instantly on mentioned when user account is set to notify on mention' do
        @comments = Factory(:comment, :target => @conversation, :user => @charles, :project => @project, :body => "Hey @all, have a look at this conversation!")
        @comments = Factory(:comment, :target => @task, :user => @charles, :project => @project, :body => "Hey @all, have a look at this task!")

        unread_emails_for(@jordi.email).size.should == 2
        unread_emails_for(@pablo.email).size.should == 2
        unread_emails_for(@james.email).size.should == 0
        unread_emails_for(@charles.email).size.should == 0
      end
    end

    def time_is_now(time)
      now = Time.now
      Time.stub(:now).and_return(time)
      yield
      Time.stub(:now).and_return(now)
    end

  end
end
