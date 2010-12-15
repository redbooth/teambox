require 'spec_helper'

describe EmailBounce do
  before do
    @owner = Factory.create(:user)
    @message = Mail.new
    @message.from = @owner.email
  end
  
  it "should assign the values of #exception_message and #exception_type when passed #exception=" do
    bounce = Factory.build(:email_bounce, :exception_message => nil, :exception_type => nil)
    bounce.exception = Emailer::Incoming::Error.new(@message, "test message")
    bounce.exception_message.should == "test message"
    bounce.exception_type.should == "error"
  end
  
  it "should find all messages created today and not those created before when sent #created_today" do
    bounce1 = Factory(:email_bounce, :created_at => DateTime.now)
    bounce1 = Factory(:email_bounce, :created_at => 5.minutes.ago)
    bounce2 = Factory(:email_bounce, :created_at => 5.hours.ago)
    bounce3 = Factory(:email_bounce, :created_at => 25.hours.ago)
    bounce4 = Factory(:email_bounce, :created_at => 32.hours.ago)
    bounce5 = Factory(:email_bounce, :created_at => 5.days.ago)
    
    EmailBounce.created_today.count.should == 3
  end
  
  it "should return false when sent #bounced_email_today with a user when the user has no bounce" do
    EmailBounce.bounced_email_today?(Factory(:user).email).should == false
  end
  
  it "should return false when sent #bounced_email_today with a user when its another users bounce" do
    bounce1 = Factory(:email_bounce, :created_at => 5.minutes.ago)
    EmailBounce.bounced_email_today?(Factory(:user).email).should == false
  end
  
  it "should return true when sent #bounced_email_today with a user when the user already has a bounce" do
    bounce1 = Factory(:email_bounce, :created_at => 5.minutes.ago)
    EmailBounce.bounced_email_today?(bounce1.email).should == true
  end
  
  it "should return false when sent #bounced_email_today with a user has an old bounce" do
    bounce1 = Factory(:email_bounce, :created_at => 26.hours.ago)
    EmailBounce.bounced_email_today?(bounce1.email).should == false
  end
  
  it "should create an entry from the exception when passed #bounce_once_per_day" do
    lambda do
      exception = Emailer::Incoming::Error.new(@message, "Our error")
      EmailBounce.bounce_once_per_day(exception)
    end.should change(EmailBounce, :count).by(1)
    
    bounce = EmailBounce.last
    bounce.email.should == @message.from.first
    bounce.exception_type.should == 'error'
    bounce.exception_message.should == 'Our error'
  end
  
  it "should only call deliver_bounce_message once per day when sent #bounce_once_per_day" do
    exception = Emailer::Incoming::Error.new(@message, "Our error")
    Emailer.should_receive(:send_with_language).with(:bounce_message, :en, exception.mail.from, exception.class.name.underscore.split('/').last).once
    
    EmailBounce.bounce_once_per_day(exception)
    EmailBounce.bounce_once_per_day(exception)
  end
end