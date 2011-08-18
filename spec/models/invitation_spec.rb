require File.dirname(__FILE__) + '/../spec_helper'

describe Invitation do
  describe "a new invitation" do
    before do
      @project = Factory.create(:project)
      @inviter = Factory.create(:user)
      @invitee = Factory.create(:user)
      @observer = Factory.create(:user)
      @project.add_user(@inviter).update_attribute(:role, Person::ROLES[:admin])
      @project.add_user(@observer).update_attribute(:role, Person::ROLES[:observer])
    end

    it "should initialize properly entering non-existing users' emails" do
      invitation = @project.new_invitation(nil, :user_or_email => "vnabokov@mail.ru")
      invitation.valid?.should be_false
      invitation.user = @inviter
      invitation.valid?.should be_true
      invitation.project.should == @project
      invitation.user.should == @inviter
      invitation.email.should == "vnabokov@mail.ru"
    end
    
    it "should initialize properly entering existing users' emails" do
      user = Factory(:user)
      invitation = @project.create_invitation(nil, :user_or_email => user.email)
      invitation.should_not be_valid
      invitation.user = @inviter
      invitation.should be_valid
      invitation.save!
      invitation.project.should == @project
      invitation.user.should == @inviter
      invitation.email.should == user.email
    end
    
    it "should find a user by her login" do
      user = Factory.create(:user)
      invitation = @project.create_invitation(@inviter, :user_or_email => user.login)
      invitation.should_not be_new_record
      invitation.user.should == @inviter
      invitation.invited_user.should == user
      invitation.email.should == user.email
    end

    it "should find a user by her email" do
      user = Factory.create(:user)
      invitation = @project.create_invitation(@inviter, :user_or_email => user.email)
      invitation.should_not be_new_record
      invitation.user.should == @inviter
      invitation.invited_user.should == user
      invitation.email.should == user.email
    end
    
    it "should send an Invitation email to existing users with autoinvite disabled" do
      user = Factory.create(:user)
      user.update_attributes(:auto_accept_invites => false)
      invitation = @project.new_invitation(@inviter, :user_or_email => user.login)
      Emailer.should_receive(:send_with_language).once
      invitation.save
      user.invitations.length.should == 1
    end

    it "should send an Invitation email to existing users with autoinvite enabled" do
      user = Factory.create(:user)
      invitation = @project.new_invitation(@inviter, :user_or_email => user.login)
      Emailer.should_receive(:send_with_language).once
      invitation.save
      user.invitations.length.should == 0
    end

    it "should send a project membership notification email to users in the inviter's organization" do
      user = Factory.create(:user)
      @project.organization.add_member(user, :participant)
      invitation = @project.new_invitation(@inviter, :user_or_email => user.login)
      Emailer.should_receive(:send_with_language).once #once for the membership notification
      invitation.save
      user.invitations.length.should == 0
    end

    it "should send a project membership notification email to non-autoaccept users in the inviter's organization" do
      user = Factory.create(:user, :auto_accept_invites => false)
      @project.organization.add_member(user, :participant)
      invitation = @project.new_invitation(@inviter, :user_or_email => user.login)
      Emailer.should_receive(:send_with_language).once #once for the membership notification
      invitation.save
      user.invitations.length.should == 1
    end
    
    it "should send a project membership notification email even when the invite is deleted" do
      user = Factory.create(:user)
      @project.organization.add_member(user, :participant)
      invitation = @project.new_invitation(@inviter, :user_or_email => user.login)
      invitation.save
      invitation.deleted?.should == true
      user.invitations.length.should == 0
      
      Emailer.send_email(:project_membership_notification, invitation.id)# rescue assert(false)
    end

    it "should not send an Invitation email to users in the inviter's organization" do
      user = Factory.create(:user)
      @project.organization.add_member(user, :participant)
      invitation = @project.new_invitation(@inviter, :user_or_email => user.login)
      Emailer.should_not_receive(:send_with_language).with(:project_invitation)
      invitation.save
    end

    it "should auto accept the invitation if the user is in the inviter's organization" do
      user = Factory.create(:user)
      @project.organization.add_member(user, :participant)
      invitation = @project.new_invitation(@inviter, :user_or_email => user.login)
      invitation.should_receive(:accept).with(user).once
      invitation.save
    end

    it "should not auto accept the invitation if the user is not in the inviter's organization" do
      user = Factory.create(:user, :auto_accept_invites => false)
      invitation = @project.new_invitation(@inviter, :user_or_email => user.login)
      Invitation.should_not_receive(:accept)
      invitation.save
    end

    it "should not destroy itself when used with non-autoaccept users and having sent the project membership notification" do
      user = Factory.create(:user, :auto_accept_invites => false)
      @project.organization.add_member(user, :participant)
      invitation = @project.new_invitation(@inviter, :user_or_email => user.login)
      Emailer.should_receive(:send_with_language).once #once for the membership notification
      invitation.save
      user.invitations.length.should == 1
      invitation.should_not be_frozen
    end

    it "should destroy itself after autoaccepting and having sent the project membership notification" do
      user = Factory.create(:user)
      @project.organization.add_member(user, :participant)
      invitation = @project.new_invitation(@inviter, :user_or_email => user.login)
      Emailer.should_receive(:send_with_language).once #once for the membership notification
      invitation.save
      user.invitations.length.should == 0
      invitation.should be_frozen
    end

    it "should create an invitation with an email but no assigned user for non-existing users" do
      invitation = @project.new_invitation(@inviter, :user_or_email => "carl.jung@hotmail.ch")
      invitation.valid?.should be_true
      invitation.invited_user.should be_nil
      invitation.email.should == "carl.jung@hotmail.ch"
    end
    
    it "should send a Signup and Invitation email to non-existing users" do
      invitation = @project.new_invitation(@inviter, :user_or_email => "carl.jung@hotmail.ch")
      Emailer.should_receive(:send_with_language).once
      invitation.save
    end
    
    it "should be invalid if the invited user string has spaces" do
      invitation = @project.new_invitation(@inviter, :user_or_email => "joe the plumber")
      invitation.should_not be_valid
    end

    it "should be invalid if it is not a proper login but not a valid email either" do
      invitation = @project.new_invitation(@inviter, :user_or_email => "sigmund freud@gmail.com")
      invitation.should_not be_valid
    end

    it "should be valid if it's a valid login" do
      invitation = @project.new_invitation(@inviter, :user_or_email => @invitee.login)
      invitation.should be_valid
    end
    
    it "should be invalid if it's an invalid login" do
      invitation = @project.new_invitation(@inviter, :user_or_email => "mokngiodngiojdiogjvdkjvg")
      invitation.should_not be_valid
    end

    it "should be valid if it's a valid email" do
      invitation = @project.new_invitation(@inviter, :user_or_email => "sigmund.freud@gmail.com")
      invitation.should be_valid
    end
    
    it "should not create duplicate invitations for a project" do
      user = Factory.create(:user, :auto_accept_invites => false)
      invitation = @project.create_invitation(@inviter, :user_or_email => user.email)
      Invitation.count.should == 1
      invitation = @project.new_invitation(@inviter, :user_or_email => user.email)
      invitation.should_not be_valid
      Invitation.delete_all
      
      # In the case of auto accept...
      user.update_attribute(:auto_accept_invites, true)
      invitation = @project.create_invitation(@inviter, :user_or_email => user.email)
      Invitation.count.should == 0
      invitation = @project.new_invitation(@inviter, :user_or_email => user.email)
      invitation.should_not be_valid
    end

    it "should not invite people already in the project when giving their email" do
      invitation = @project.create_invitation(@inviter, :user_or_email => @project.users.first.email)
      invitation.should_not be_valid
    end

    it "should not invite people already in the project when giving their username" do
      invitation = @project.create_invitation(@inviter, :user_or_email => @project.users.first.login)
      invitation.should_not be_valid
    end
    
    it "should be not valid if an observer creates it" do
      invitation = @project.new_invitation(@observer, :user_or_email => "sigmund.freud@gmail.com")
      invitation.should_not be_valid
    end
    
    it "should be not valid if a deleted user creates it" do
      uname = @inviter.login
      @inviter.destroy
      @inviter = User.find_by_login(uname)
      invitation = @project.new_invitation(@inviter, :user_or_email => "sigmund.freud@gmail.com")
      invitation.should_not be_valid
    end
    
    it "should still return a valid inviter if they are deleted" do
      invitation = @project.new_invitation(@inviter, :user_or_email => "sigmund.freud@gmail.com")
      invitation.save
      @inviter.destroy
      invitation.reload
      invitation.user.should_not == nil
    end
  end
  
  describe "an existing invitation" do
    before do
      @project = Factory.create(:project)
    end

    it "can resend an email to an already invited user with an account who hasn't accepted" do
      user = Factory.create(:user)
      invitation = @project.new_invitation(@project.user, :user_or_email => user.login)
      Emailer.should_receive(:send_with_language).once
      invitation.save!
    end

    it "can resend an email to an already invited user without an account who hasn't accepted" do
      invitation = @project.new_invitation(@project.user, :user_or_email => "carl.jung@hotmail.ch")
      Emailer.should_receive(:send_with_language).once
      invitation.save!
    end
  end
end
