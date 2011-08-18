require 'spec_helper'

describe ApiV1::InvitationsController do

  describe "#resend" do
    it "resends an invite" do
      invitation = Factory.create :invitation
      login_as invitation.user
      request.env['HTTP_REFERER'] = 'http://test.host/page'

      lambda {
        put :resend, :id => invitation.id, :project_id => invitation.project.permalink
        response.should be_ok
      }.should change(all_emails, :size)

      last_email_sent.should deliver_to(invitation.email)
    end
  end

  describe "#create" do
    before do
      @users = []
      @emails = "foo@localhost.com billg@microsoft.com fred@teambox.com"
      5.times { @users << Factory(:user, :auto_accept_invites => false) }
      @project = Factory.create(:project)
    end

    it "creates users for emails" do
      login_as @project.user
      
      lambda {
        post :create, :project_id => @project.permalink, :email => 'foo@localhost.com', :first_name => 'Joe', :last_name => 'Bloggs'
      }.should change(User, :count)
      
      response.should be_success
      
      Invitation.count.should == 1
      
      user = User.order('id DESC').first
      user.email.should == 'foo@localhost.com'
      user.profile_needs_completing?.should == true
    end

    it "accepts usernames as existing users" do
      login_as @project.user
      post :create, :project_id => @project.permalink, :user_or_email => @users.map(&:login).join(' ')
      response.should be_success

      @project.invitations(true).length.should == 5
      @project.invitations.each { |invite| (@users.include?(invite.invited_user)).should == true }
    end

    it "accepts both emails and usernames" do
      login_as @project.user
      list = @users.map(&:login).join(' ') + ' ' + @emails
      post :create, :project_id => @project.permalink, :user_or_email => list
      response.should be_success

      @project.invitations(true).length.should == @users.count + 3
    end
  end

end

