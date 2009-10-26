require File.dirname(__FILE__) + '/../spec_helper'

describe Invitation do
  describe "inviting" do
    before do
      @project = Factory(:project)
    end

    it "should find a user by her login" do
      user = Factory.create(:user)
      invitation = @project.invitations.new(:user_or_email => user.login)
      invitation.valid?.should be_true
      invitation.user.should == user
      invitation.email.should == user.email
    end

    it "should find a user by her email" do
      user = Factory.create(:user)
      invitation = @project.invitations.new(:user_or_email => user.email)
      invitation.valid?.should be_true
      invitation.user.should == user
      invitation.email.should == user.email
    end
    
    it "should send an Invitation email to existing users" do
      user = Factory.create(:user)
      Emailer.should_receive(:project_invitation).with(user).once
      invitation = @project.invitations.create(:user_or_email => user.login)
      user.invitations.length.should == 1
    end

    it "should create an invitation with an email but no assigned user for non-existing users" do
      invitation = @project.invitations.new(:user_or_email => "carl.jung@hotmail.ch")
      invitation.valid?.should be_true
      invitation.user.should be_nil
      invitation.email.should == "carl.jung@hotmail.ch"
    end
    
    it "should send a Signup and Invitation email to non-existing users" do
      Emailer.should_receive(:signup_and_project_invitation).with("variable").once
      invitation = @project.invitations.new(:user_or_email => "carl.jung@hotmail.ch")
    end
    
    it "should be invalid if is not an email or login" do
      invitation = @project.invitations.new(:user_or_email => "definitely not an email or username")
      invitation.valid?.should be_false
    end
    
    it "should not create duplicate invitations for a project" do
      user = Factory.create(:user)
      invitation = @project.invitations.create(:user_or_email => user.email)
      Invitation.count.should == 1
      invitation = @project.invitations.new(:user_or_email => user.email)
      invitation.valid?.should be_false
    end

    it "should not invite people already in the project when giving their email" do
      invitation = @project.invitations.create(:user_or_email => @project.users.first.email)
      invitation.valid?.should be_false
    end

    it "should not invite people already in the project when giving their username" do
      invitation = @project.invitations.create(:user_or_email => @project.users.first.login)
      invitation.valid?.should be_false
    end
  end
end
