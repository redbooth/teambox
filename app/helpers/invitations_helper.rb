module InvitationsHelper
  def invitation_fields(f)
    render :partial => 'invitations/fields', :locals => { :f => f }
  end
  
  def list_invitations(invitations)
    render :partial => 'invitations/invitation', :collection => invitations
  end
  
  def list_user_invitations(invitations)
    render :partial => 'invitations/user_invitation', :collection => invitations, :as => :invitation
  end  
  
  def delete_invitation_link(invitation)
    link_to_remote trash_image,
      :url => project_invitation_path(invitation.project,invitation),
      :method => :delete
  end
  
  def new_invitation_link(project)
    link_to 'Invite someone', new_project_invitation_path(project)
  end
end