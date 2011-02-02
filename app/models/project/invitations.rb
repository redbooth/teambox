require_dependency 'extract_emails'

class Project

  # array of user IDs
  attr_accessor :invite_users
  # string with email addresses
  attr_accessor :invite_emails

  # if any of the invitation parameters are defined, send invitations
  def invite_people?
    invite_users.present? or invite_emails.present?
  end

  after_create :send_invitations!, :if => :invite_people?

  def send_invitations!
    return unless invite_people?
    users_to_invite = User.find(Array.wrap invite_users)
    emails_to_invite = invite_emails.to_s.extract_emails - users_to_invite.map(&:email)

    for user in users_to_invite
      create_invitation(self.user, :invited_user => user)
    end

    for email in emails_to_invite
      create_invitation(self.user, :user_or_email => email)
    end
  end

end
