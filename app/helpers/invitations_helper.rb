module InvitationsHelper

  def list_pending_invites(invitations)
    render :partial => 'invitations/pending', :as => :invitation, :collection => invitations
  end
  
  def delete_invitation_link(invitation)
    if invitation.editable?(current_user)
      target = invitation.target
      link_to_remote t('invitations.invitation.discard'),
        :url => project_invitation_path(target,invitation),
        :method => :delete
    end
  end
  
  def resend_invitation_link(target,invitation)
    if invitation.editable?(current_user)
      
      link_to_remote t('invitations.invitation.resend'),
        :url => resend_project_invitation_path(target,invitation),
        :loading => show_loading('resend_invitation',invitation.id),
        :html => { :id => "resend_invitation_#{invitation.id}_link" }
    end
  end
  
  def invitation_sent(invitation)
    page.replace "resend_invitation_loading_#{invitation.id}",
      :partial => 'invitations/sent'
  end
  
  def invite_user(project,user)
    link_to t('.invite', :username => h(user.name)), '#', :class => 'invite_user', :login => user.login
  end
end