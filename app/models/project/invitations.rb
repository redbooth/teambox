require_dependency 'extract_emails'

class Project

  # array of user IDs
  attr_accessor :invite_users
  # string with email addresses
  attr_accessor :invite_emails
  
  def invite_people?
    invite_users.present? or invite_emails.present?
  end
  
  after_create :send_invitations, :if => :invite_people?
  
  protected

  def send_invitations
    users_to_invite = User.find(Array.wrap(invite_users))
    emails_to_invite = invite_emails.to_s.extract_emails - users_to_invite.map(&:email)
    
    for user in users_to_invite
      invitations.create!(:user => self.user, :invited_user => user)
    end
    
    for email in emails_to_invite
      invitations.create!(:user => self.user, :user_or_email => email)
    end
  end
end