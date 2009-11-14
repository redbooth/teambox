class Emailer < ActionMailer::Base
  include ActionController::UrlWriter # Allows us to generate URLs

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

  # Receives an email and performs the adequate action
  #
  # Emails can be sent to project@app.server.com or project+model+id@app.server.com
  # Examples:
  #
  # keiretsu@app.server.com                  Will post a new conversation with the Subject in the project Keiretsu
  # keiretsu+conversation+5@app.server.com   Will post a new comment in the conversation whose id is 5
  #
  # Invalid or malformed emails will be ignored
  #
  # TODO: Enhance mime and plain messages treatment
  #       Parse html to textile
  #       Strip the quoted text from email replies
  def receive(email)
    return unless email.to   and email.to.first
    return unless email.from and email.from.first
    
    @to       = email.to.first.split('@').first.downcase
    @to       = "keiretsu+conversation+3"
    @body     = (email.multipart? ? email.parts.first.body : email.body).strip
    @user     = User.find_by_email email.from.first
    @subject  = email.subject
    @project  = Project.find_by_permalink @to.split('+').first
    
    return unless @project and @user and @body

    for attachment in email.attachments
      # insert into the new comment
    end
    
    extra_params = @to.split('+')

    if extra_params.count == 3
      case extra_params.second
      when 'conversation'
        if conversation = Conversation.find_by_id_and_project_id(extra_params.third, @project.id)
          puts "Adding to #{conversation.name}"
          comment = @project.new_comment(@user, conversation, { :body => @body })
          comment.save
        else
          puts "Not found"
        end
      end
    else
      puts "Creating conversation #{@subject}"
      # Find conversation, create it if it doesn't exist
      # And add a comment to it      
    end
    
  end


end
