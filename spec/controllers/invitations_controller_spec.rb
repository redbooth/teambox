require 'spec_helper'

describe InvitationsController do
  
  describe "#resend" do
    it "resends an invite" do
      invitation = Factory.create :invitation
      login_as invitation.user
      request.env['HTTP_REFERER'] = 'http://test.host/page'
      
      lambda {
        put :resend, :id => invitation.id, :project_id => invitation.project.permalink
        response.should redirect_to("http://test.host/projects/#{invitation.project.permalink}/people")
      }.should change(all_emails, :size)
      
      last_email_sent.should deliver_to(invitation.email)
    end
  end
  
  describe "#create" do
    before do
      @users = []
      @emails = "foo@localhost.com billg@microsoft.com fred@teambox.com"
      5.times { @users << Factory(:user) }
      @project = Factory.create(:project)
    end
    
    it "accepts email addresses as email addresses" do
      login_as @project.user
      post :create, :project_id => @project.permalink, :invitation => {:user_or_email => @emails}
      @project.invitations(true).length.should == 3
      @project.invitations.each { |invite| invite.invited_user.should == nil }
      @project.invitations.destroy_all
    end
    
    it "accepts usernames as existing users" do
      login_as @project.user
      post :create, :project_id => @project.permalink,  :invitation => {:user_or_email => @users.map(&:login).join(' ')}
      @project.invitations(true).length.should == 5
      @project.invitations.each { |invite| (@users.include?(invite.invited_user)).should == true }
      @project.invitations.destroy_all
    end
    
    it "only accepts emails when valid email addresses are present" do
      login_as @project.user
      list = @users.map(&:login).join(' ') + ' ' + @emails
      post :create, :project_id => @project.permalink,  :invitation => {:user_or_email => list}
      @project.invitations(true).length.should == 3
      @project.invitations.each { |invite| invite.invited_user.should == nil }
      @project.invitations.destroy_all
    end
  
  end
  
end
