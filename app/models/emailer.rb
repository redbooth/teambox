class Emailer < ActionMailer::Base
  include ActionController::UrlWriter # Allows us to generate URLs
  concerned_with :receive

  def confirm_email(user)
    recipients    user.email
    from          "Teambox <no-reply@#{APP_CONFIG['email_domain']}>"
    subject       'Get started with Teambox!'
    content_type  'text/html'
    sent_on       Time.now
    body          :user => user, :login_link => confirm_email_user_url(user, :token => user.login_token)
  end

  def reset_password(user)
    recipients    user.email
    from          "Teambox <no-reply@#{APP_CONFIG['email_domain']}>"
    subject       'Your password has successfully been reset!'
    content_type  'text/html'
    sent_on       Time.now
    body          :user => user
  end

  def forgot_password(reset_password)
    recipients    reset_password.email
    from          "Teambox <no-reply@#{APP_CONFIG['email_domain']}>"
    subject       'Password retrieval for Teambox'
    content_type  'text/html'
    sent_on       Time.now
    body          :user => reset_password.user, :url => reset_password_url(reset_password.reset_code)
  end

  def project_invitation(invitation)
    recipients    invitation.email
    from          "Teambox <no-reply@#{APP_CONFIG['email_domain']}>"
    subject       "#{invitation.user.name} shared [#{invitation.project.name}] with you"
    content_type  'text/html'
    sent_on       Time.now
    body          :referral => invitation.user, :project => invitation.project, :invitation => invitation
  end

  def signup_invitation(invitation)
    recipients    invitation.email
    from          "Teambox <no-reply@#{APP_CONFIG['email_domain']}>"
    subject       "#{invitation.user.name} shared [#{invitation.project.name}] with you"
    content_type  'text/html'
    sent_on       Time.now
    body          :referral => invitation.user, :project => invitation.project, :invitation => invitation
  end

  def notify_conversation(recipient, project, comment, conversation)
    recipients    recipient
    from          "Teambox <#{project.permalink}@#{APP_CONFIG['email_domain']}>"
    subject       "[#{project.permalink}] #{conversation.name}"
    content_type  "text/html"
    sent_on       Time.now
    reply_to      "Teambox <#{project.permalink}+conversation+#{conversation.id}@#{APP_CONFIG['email_domain']}>"
    body          :project => project, :comment => comment, :conversation => conversation
  end

end
