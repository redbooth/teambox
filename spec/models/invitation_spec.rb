require File.dirname(__FILE__) + '/../spec_helper'

describe Invitation do
  describe "a new invitation" do
    before do
      @project = Factory.create(:project)
      @inviter = Factory.create(:user)
    end

    it "should find a user by her login" do
      user = Factory.create(:user)
      invitation = @project.invitations.new(:user_or_email => user.login, :user => @inviter)
      invitation.valid?.should be_true
      invitation.user.should == @inviter
      invitation.invited_user.should == user
      invitation.email.should == user.email
    end

    it "should find a user by her email" do
      user = Factory.create(:user)
      invitation = @project.invitations.new(:user_or_email => user.email, :user => @inviter)
      invitation.valid?.should be_true
      invitation.user.should == @inviter
      invitation.invited_user.should == user
      invitation.email.should == user.email
    end
    
    it "should send an Invitation email to existing users" do
      user = Factory.create(:user)
      invitation = @project.invitations.new(:user_or_email => user.login, :user => @inviter)
      Emailer.should_receive(:deliver_project_invitation).with(invitation).once
      invitation.save
      user.invitations.length.should == 1
    end

    it "should create an invitation with an email but no assigned user for non-existing users" do
      invitation = @project.invitations.new(:user_or_email => "carl.jung@hotmail.ch", :user => @inviter)
      invitation.valid?.should be_true
      invitation.invited_user.should be_nil
      invitation.email.should == "carl.jung@hotmail.ch"
    end
    
    it "should send a Signup and Invitation email to non-existing users" do
      invitation = @project.invitations.new(:user_or_email => "carl.jung@hotmail.ch", :user => @inviter)
      Emailer.should_receive(:deliver_signup_invitation).once
      invitation.save
    end
    
    it "should be invalid if is not an email or login" do
      invitation = @project.invitations.new(:user_or_email => "definitely not an email or username")
      invitation.valid?.should be_false
    end
    
    it "should not create duplicate invitations for a project" do
      user = Factory.create(:user)
      invitation = @project.invitations.create(:user_or_email => user.email, :user => @inviter)
      Invitation.count.should == 1
      invitation = @project.invitations.new(:user_or_email => user.email, :user => @inviter)
      invitation.valid?.should be_false
    end

    it "should not invite people already in the project when giving their email" do
      invitation = @project.invitations.create(:user_or_email => @project.users.first.email, :user => @inviter)
      invitation.valid?.should be_false
    end

    it "should not invite people already in the project when giving their username" do
      invitation = @project.invitations.create(:user_or_email => @project.users.first.login, :user => @inviter)
      invitation.valid?.should be_false
    end
  end
  
  describe "an existing invitation" do
    before do
      @project = Factory.create(:project)
      @inviter = Factory.create(:user)
    end

    it "can resend an email to an already invited user with an account who hasn't accepted" do
      user = Factory.create(:user)
      invitation = @project.invitations.create(:user_or_email => user.login, :user => @inviter)
      Emailer.should_receive(:deliver_project_invitation).with(invitation).once
      invitation.send_email
    end

    it "can resend an email to an already invited user without an account who hasn't accepted" do
      invitation = @project.invitations.create(:user_or_email => "carl.jung@hotmail.ch", :user => @inviter)
      Emailer.should_receive(:deliver_signup_invitation).with(invitation).once
      invitation.send_email
    end
  end
end
