require File.dirname(__FILE__) + '/../spec_helper'

describe Invitation do
  describe "preinviting users on project creation" do
    before do
      @project = Factory(:project)
    end

    describe "preloading invitations" do
      it "should not invite anybody by default" do
        @project.invited_users.should == nil
        @project.invited_emails.should == nil
      end

      it "should invite a new user from 'invite_emails' field" do
        @project.preinvite_emails("hey@man.com")
        @project.invited_emails.should == ["hey@man.com"]
      end

      it "should invite two new users from 'invite_emails' field" do
        @project.preinvite_emails("- gitar@come.to\n 'my@buduar.com' a@s")
        @project.invited_emails.should == %w(gitar@come.to my@buduar.com)
      end

      it "should not invite duplicate emails" do
        @project.preinvite_emails("a@b.com b@c.es")
        @project.preinvite_emails("b@c.es j@k.co.uk")
        @project.invited_emails.should == %w(a@b.com b@c.es j@k.co.uk)
      end

      it "should invite users passing the user model" do
        user1 = Factory(:user)
        user2 = Factory(:user)
        @project.preinvite_users([user1, user2])
        @project.invited_emails.should == nil
        @project.invited_users.should == [user1,user2]
      end

      it "should invite users with their email" do
        user1 = Factory(:user)
        user2 = Factory(:user)
        @project.preinvite_emails %Q(#{user1.email} #{user2.email})
        @project.invited_emails.should == []
        @project.invited_users.should == [user1,user2]
      end

      it "should invite users with their email" do
        user1 = Factory(:user)
        user2 = Factory(:user)
        @project.preinvite_emails user1.email
        @project.preinvite_users user2
        @project.invited_emails.should == []
        @project.invited_users.should == [user1,user2]
      end

      it "should invite existing users and new ones" do
        user1 = Factory(:user)
        user2 = Factory(:user)
        @project.preinvite_emails %Q(#{user1.email} invalid new@user.dk)
        @project.preinvite_users user2
        @project.invited_emails.should == %w(new@user.dk)
        @project.invited_users.should == [user1,user2]
      end

      it "should not duplicate users when inviting by email and user" do
        user1 = Factory(:user)
        @project.preinvite_emails user1.email
        @project.preinvite_users user1
        @project.invited_emails.should == []
        @project.invited_users.should == [user1]
      end
    end
    
    describe "sending preloaded invitations" do
      it "should not send invitations for an unsaved project" do
        project = Factory.build(:project)
        begin
          project.send_invitations
          raise "Send invitations didn't fail"
        rescue
          $!.to_s.should == "Project must be saved before sending the invites"
        end
      end

      it "should invite new users by email" do
        @project.preinvite_emails "new@user.br"
        @project.send_invitations
        @project.invitations.first.user.should == @project.user
        @project.invitations.first.invited_user.should == nil
        @project.invitations.first.email.should == "new@user.br"
      end

      it "should invite existing users" do
        user = Factory(:user)
        @project.preinvite_users user
        @project.send_invitations
        @project.invitations.first.user.should == @project.user
        @project.invitations.first.invited_user.should == user
        @project.invitations.first.email.should == user.email
      end

      it "should not invite users already on the project" do
        @project.preinvite_emails @project.user.email
        @project.preinvite_users @project.user
        @project.send_invitations
        Invitation.count.should == 0
      end
    end
  end

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
      invitation = @project.invitations.new(:user_or_email => "vnabokov@mail.ru")
      invitation.valid?.should be_false
      invitation.user = @inviter
      invitation.valid?.should be_true
      invitation.project.should == @project
      invitation.user.should == @inviter
      invitation.email.should == "vnabokov@mail.ru"
    end
    
    it "should initialize properly entering existing users' emails" do
      user = Factory(:user)
      invitation = @project.invitations.create(:user_or_email => user.email)
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
      invitation = @project.invitations.create(:user_or_email => user.login, :user => @inviter)
      invitation.should_not be_new_record
      invitation.user.should == @inviter
      invitation.invited_user.should == user
      invitation.email.should == user.email
    end

    it "should find a user by her email" do
      user = Factory.create(:user)
      invitation = @project.invitations.create(:user_or_email => user.email, :user => @inviter)
      invitation.should_not be_new_record
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
    
    it "should be invalid if the invited user string has spaces" do
      invitation = @project.invitations.new(:user_or_email => "joe the plumber", :user => @inviter)
      invitation.should_not be_valid
    end

    it "should be invalid if it is not a proper login but not a valid email either" do
      invitation = @project.invitations.new(:user_or_email => "sigmund freud@gmail.com", :user => @inviter)
      invitation.should_not be_valid
    end

    it "should be valid if it's a valid login" do
      invitation = @project.invitations.new(:user_or_email => @invitee.login, :user => @inviter)
      invitation.should be_valid
    end
    
    it "should be invalid if it's an invalid login" do
      invitation = @project.invitations.new(:user_or_email => "mokngiodngiojdiogjvdkjvg", :user => @inviter)
      invitation.should_not be_valid
    end

    it "should be valid if it's a valid email" do
      invitation = @project.invitations.new(:user_or_email => "sigmund.freud@gmail.com", :user => @inviter)
      invitation.should be_valid
    end
    
    it "should not create duplicate invitations for a project" do
      user = Factory.create(:user)
      invitation = @project.invitations.create(:user_or_email => user.email, :user => @inviter)
      Invitation.count.should == 1
      invitation = @project.invitations.new(:user_or_email => user.email, :user => @inviter)
      invitation.should_not be_valid
    end

    it "should not invite people already in the project when giving their email" do
      invitation = @project.invitations.create(:user_or_email => @project.users.first.email, :user => @inviter)
      invitation.should_not be_valid
    end

    it "should not invite people already in the project when giving their username" do
      invitation = @project.invitations.create(:user_or_email => @project.users.first.login, :user => @inviter)
      invitation.should_not be_valid
    end
    
    it "should be not valid if an observer creates it" do
      invitation = @project.invitations.new(:user_or_email => "sigmund.freud@gmail.com", :user => @observer)
      invitation.should_not be_valid
    end
    
    it "should be not valid if a deleted user creates it" do
      uname = @inviter.login
      @inviter.destroy
      @inviter = User.find_by_login(uname)
      invitation = @project.invitations.new(:user_or_email => "sigmund.freud@gmail.com", :user => @inviter)
      invitation.should_not be_valid
    end
  end
  
  describe "an existing invitation" do
    before do
      @project = Factory.create(:project)
    end

    it "can resend an email to an already invited user with an account who hasn't accepted" do
      user = Factory.create(:user)
      invitation = @project.invitations.new(:user_or_email => user.login, :user => @project.user)
      Emailer.should_receive(:deliver_project_invitation).with(invitation).once
      invitation.save!
    end

    it "can resend an email to an already invited user without an account who hasn't accepted" do
      invitation = @project.invitations.new(:user_or_email => "carl.jung@hotmail.ch", :user => @project.user)
      Emailer.should_receive(:deliver_signup_invitation).with(invitation).once
      invitation.save!
    end
  end
end
