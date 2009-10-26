module InvitationsHelper

  def list_invitations(invitations)
    render :partial => 'invitations/invitations', :collection => invitations
  end

  def invitation_fields(f)
    render :partial => 'invitations/fields', :locals => { :f => f }
  end
  
  def list_invitations(invitations)
    render :partial => 'invitations/invitation', :collection => invitations
  end

  def list_pending_invites(invitations)
    render :partial => 'invitations/pending', :as => :invitation, :collection => invitations
  end
  
  def delete_invitation_link(invitation)
    link_to_remote trash_image,
      :url => project_invitation_path(invitation.project,invitation),
      :method => :delete
  end
  
  def new_invitation_link(project)
    link_to 'Invite someone', new_project_invitation_path(project)
  end
  
  def resend_invitation_link(invitation)
    link_to t('.resend'), resend_project_invitation_path(invitation.project,invitation)
  end
end