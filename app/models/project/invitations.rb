class Project

  attr_reader :invited_users, :invited_emails

  def preinvite_emails(emails)
    @invited_emails = Array.wrap(@invited_emails)
    @invited_users = Array.wrap(@invited_users)
    @invited_users += User.find_all_by_email(emails.extract_emails)
    @invited_users.uniq!
    existing_emails = @invited_users.collect { |user| user.email }
    @invited_emails += emails.extract_emails.reject { |email| existing_emails.include? email }
    @invited_emails.uniq!
  end

  def preinvite_users(users)
    @invited_users ||= []
    @invited_users += Array.wrap(users)
    @invited_users.uniq!
  end

  def send_invitations
    raise "Project must be saved before sending the invites" if new_record?

    for user in Array(@invited_users).reject { |u| users.include? u }
      invitation = invitations.new(:user_or_email => user.email)
      invitation.role = 3 # admin
      invitation.user = self.user
      invitation.save!
    end

    for email in Array.wrap(@invited_emails)
      invitation = invitations.new(:user_or_email => email)
      invitation.role = 3 # admin
      invitation.user = self.user
      invitation.save!
    end    
  end
end
