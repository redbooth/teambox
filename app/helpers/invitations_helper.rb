module InvitationsHelper

  def list_invitations(invitations)
    render :partial => 'invitations/invitations', :collection => invitations
  end

  def invitation_fields(f)
    render :partial => 'invitations/fields', :locals => { :f => f }
  end
  
  def list_invitations_for_project(project,invitations)
    render :partial => 'invitations/invitation', :collection => invitations,
    :locals => { :project => project }
  end

  def list_pending_invites(invitations)
    render :partial => 'invitations/pending', :as => :invitation, :collection => invitations
  end
  
  def delete_invitation_link(invitation)
    if invitation.editable?(current_user)
      link_to_remote t('.discard'),
        :url => project_invitation_path(invitation.project,invitation),
        :method => :delete
    end
  end
  
  def new_invitation_link(project)
    link_to 'Invite someone', new_project_invitation_path(project)
  end
  
  def resend_invitation_link(project,invitation)
    if invitation.editable?(current_user)
      link_to_remote t('.resend'),
        :url => resend_project_invitation_path(project,invitation),
        :loading => show_loading('resend_invitation',invitation.id),
        :html => { :id => "resend_invitation_#{invitation.id}_link" }
    end
  end
  
  def invitation_sent(invitation)
    page.replace "resend_invitation_loading_#{invitation.id}",
      :partial => 'invitations/sent'
  end

  def invite_form(project,invitation)
    if project.admin?(current_user)
      render :partial => 'invitations/new',
        :locals => {
          :project => project,
          :invitation => invitation }
    end
  end

  def invite_by_search(project,invitation)
    render :partial => 'invitations/search',
      :locals => {
        :project => project,
        :invitation => invitation }
  end

  def invite_recent(project,recent_users)
    render :partial => 'invitations/recent',
      :locals => {
        :project => project,
        :recent_users => recent_users }
  end
  
  def invite_user(project,user)
    link_to t('.invite', :username => user.name), '#', :class => 'invite_user', :login => user.login
  end
  
  def invite_user_loading(project,user)
    update_page do |page|
    end
  end
  
  def invitation_id(element,project,user)
    js_id(element,project,user)
  end
end