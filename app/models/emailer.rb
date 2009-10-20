class Emailer < ActionMailer::Base
  include ActionController::UrlWriter # Allows us to generate URLs

  def confirm_email(user)
    recipients    user.email
    from          'Teambox <no-reply@teambox.com>'
    subject       'Get started with Teambox!'
    content_type  'text/html'
    sent_on       Time.now
    body          :user => user
  end

  def invitation(recipient, project, invitation)
    recipients    recipient
    from          'Teambox <no-reply@teambox.com>'
    subject       "#{invitation.user.name} shared [#{project.name}] with you"
    content_type  'text/html'
    sent_on       Time.now
    reply_to      'Teambox <no-reply@teambox.com>'
    body          :referral => invitation.user, :project => project, :invitation => invitation
  end

  def notify_conversation(recipient, project, comment, conversation)
    default_url_options[:host] = "sandbox.teambox.com"
    recipients    recipient
    from          "Teambox <#{project.permalink}@teambox.com>"
    subject       "[#{project.permalink}] #{conversation.name}"
    content_type  "text/html"
    sent_on       Time.now
    reply_to      "Teambox <#{project.permalink}+conversation+#{conversation.id}@teambox.com>"
    body          :project => project, :comment => comment, :conversation => conversation
  end

  # Receives an email and performs the adequate action
  #
  # Emails can be sent to project@teambox.com or project+model+id@teambox.com
  # Examples:
  #
  # keiretsu@teambox.com                  Will post a new conversation with the Subject in the project Keiretsu
  # keiretsu+conversation+5@teambox.com   Will post a new comment in the conversation whose id is 5
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
