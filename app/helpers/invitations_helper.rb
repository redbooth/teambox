module InvitationsHelper
  def invitation_fields(f)
    render :partial => 'invitations/fields', :locals => { :f => f }
  end
end