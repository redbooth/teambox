module InvitationsHelper

  def list_invitations(invitations)
    render :partial => 'invitations/invitations', :collection => invitations
  end

  def invitation_fields(f)
    render :partial => 'invitations/fields', :locals => { :f => f }
  end
  
  def list_invitations(project,invitations)
    render :partial => 'invitations/invitation', :collection => invitations,
    :locals => { :project => project }
  end

  def list_pending_invites(invitations)
    render :partial => 'invitations/pending', :as => :invitation, :collection => invitations
  end
  
  def delete_invitation_link(invitation)
    return unless invitation.editable?(current_user)
    link_to_remote trash_image,
      :url => project_invitation_path(invitation.project,invitation),
      :method => :delete
  end
  
  def new_invitation_link(project)
    link_to 'Invite someone', new_project_invitation_path(project)
  end
  
  def resend_invitation_link(project,invitation)
    return unless invitation.editable?(current_user)
    link_to_remote t('.resend'),
      :url => resend_project_invitation_path(project,invitation),
      :loading => show_loading('resend_invitation',invitation.id),
      :html => { :id => "resend_invitation_#{invitation.id}_link" }
  end
  
  def invitation_sent(invitation)
    page.replace "resend_invitation_loading_#{invitation.id}",
      :partial => 'invitations/sent'
  end

  def invite_form(project,invitation)
    return unless project.editable?(current_user)
    render :partial => 'invitations/new', :locals => {
      :project => project,
      :invitation => invitation }
  end

  
end