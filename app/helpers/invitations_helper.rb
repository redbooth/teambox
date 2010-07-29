module InvitationsHelper

  def list_invitations_for_group(group,invitations)
    render :partial => 'invitations/group_invitation', :collection => invitations,
      :locals => { :group => group, :project => nil, :target => group }
  end

  def list_pending_invites(invitations)
    render :partial => 'invitations/pending', :as => :invitation, :collection => invitations
  end
  
  def delete_invitation_link(invitation)
    if invitation.editable?(current_user)
      target = invitation.target
      link = target.class == Project ? project_invitation_path(target,invitation) : group_invitation_path(target,invitation)
      link_to_remote t('invitations.invitation.discard'),
        :url => link,
        :method => :delete
    end
  end
  
  def resend_invitation_link(target,invitation)
    if invitation.editable?(current_user)
      link = target.class == Project ? resend_project_invitation_path(target,invitation) : resend_group_invitation_path(target,invitation)
      link_to_remote t('invitations.invitation.resend'),
        :url => link,
        :loading => show_loading('resend_invitation',invitation.id),
        :html => { :id => "resend_invitation_#{invitation.id}_link" }
    end
  end
  
  def invitation_sent(invitation)
    page.replace "resend_invitation_loading_#{invitation.id}",
      :partial => 'invitations/sent'
  end
  
  def invite_user(project,user)
    link_to t('.invite', :username => user.name), '#', :class => 'invite_user', :login => user.login
  end
  
  def invitation_id(element,project,user)
    js_id(element,project,user)
  end
end