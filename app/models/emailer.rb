class Emailer < ActionMailer::Base
  include ActionController::UrlWriter # Allows us to generate URLs

  def invitation(recipient,project,invitation)
    recipients    recipient
    from          'invitation@teambox.com'
    subject       'Invitation to Teambox'
    content_type  'text/html'
    sent_on       Time.now
    reply_to      'no-reply@teambox.com'
    body          :recipient => recipient, :project => project, :invitation => invitation
  end

  def notify_conversation(recipient, project, comment, conversation)
    recipients    recipient
    from          "#{project.permalink}@teambox.com"
    subject       "[#{project.permalink}] #{conversation.name}"
    content_type  "text/html"
    sent_on       Time.now
    reply_to      "#{project.permalink}+conversation+#{conversation.id}@teambox.com"
    body          :recipient => recipient, :project => project, :comment => comment, :conversation => conversation
  end

end
