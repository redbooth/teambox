require 'spec_helper'

describe InvitationsController do
  
  describe "#resend" do
    it "resends an invite" do
      invitation = Factory.create :invitation
      login_as invitation.user
      request.env['HTTP_REFERER'] = 'http://test.host/page'
      
      lambda {
        put :resend, :id => invitation.id, :project_id => invitation.project.permalink
        response.should redirect_to('http://test.host/page')
      }.should change(all_emails, :size)
      
      last_email_sent.should deliver_to(invitation.email)
    end
  end
  
end