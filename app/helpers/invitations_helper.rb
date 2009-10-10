module InvitationsHelper

  def list_invitations(invitations)
    render :partial => 'invitations/invitations', :collection => invitations
  end

  def invitation_fields(f)
    render :partial => 'invitations/fields', :locals => { :f => f }
  end
end