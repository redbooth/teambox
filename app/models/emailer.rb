class Emailer < ActionMailer::Base
  include ActionController::UrlWriter # Allows us to generate URLs
  concerned_with :receive

  def confirm_email(user)
    defaults
    recipients    user.email
    subject       'Get started with Teambox!'
    body          :user => user, :login_link => confirm_email_user_url(user, :token => user.login_token)
  end

  def reset_password(user)
    defaults
    recipients    user.email
    subject       'Your password has successfully been reset!'
    body          :user => user
  end

  def forgot_password(reset_password)
    defaults
    recipients    reset_password.email
    subject       'Password retrieval for Teambox'
    body          :user => reset_password.user, :url => reset_password_url(reset_password.reset_code)
  end

  def project_invitation(invitation)
    defaults
    recipients    invitation.email
    subject       "#{invitation.user.name} shared [#{invitation.project.name}] with you"
    body          :referral => invitation.user, :project => invitation.project, :invitation => invitation
  end

  def signup_invitation(invitation)
    defaults
    recipients    invitation.email
    subject       "#{invitation.user.name} shared [#{invitation.project.name}] with you"
    body          :referral => invitation.user, :project => invitation.project, :invitation => invitation
  end

  def notify_conversation(recipient, project, comment, conversation)
    defaults
    recipients    recipient
    from          from_address(project.permalink)
    reply_to      from_address("#{project.permalink}+conversation+#{conversation.id}")
    subject       "[#{project.permalink}] #{conversation.name}"
    body          :project => project, :comment => comment, :conversation => conversation
  end

  private
  
    def from_address(recipient = "no-reply", name = "Teambox")
      "#{name} <#{recipient}@#{APP_CONFIG['outgoing']['from']}>"
    end

    def defaults
      content_type  'text/html'
      sent_on       Time.now
      from          from_address
    end
end
