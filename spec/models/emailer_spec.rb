require 'spec_helper'

describe Emailer do
  context "notify_conversation" do
    before do
      @conversation = Factory(:conversation)
      @user = @conversation.user
      @project = @conversation.project
      @address = %(#{@project.permalink}+conversation+#{@conversation.id}@domain.com)
      @full_address = %(#{@user.name} <#{@address}>)
    end
  
    it "should set Reply-to" do
      allow_incoming_mail do
        email = Emailer.create_notify_conversation(@user, @conversation.project, @conversation)
        email.from_addrs.first.decoded.should == @full_address
        email.reply_to.should == [@address]
      end
    end
  
    it "should not set Reply-to for no-reply" do
      allow_incoming_mail(false) do
        email = Emailer.create_notify_conversation(@user, @conversation.project, @conversation)
        email.from.should == ['no-reply@domain.com']
        email.reply_to.should be_nil
      end
    end
  end
  
  def allow_incoming_mail(really = true)
    old_value = Teambox.config.allow_incoming_email
    Teambox.config.allow_incoming_email = really
    begin
      yield
    ensure
      Teambox.config.allow_incoming_email = old_value
    end
  end
end
