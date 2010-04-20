class Emailer < ActionMailer::Base
  include ActionController::UrlWriter # Allows us to generate URLs
  include ActionView::Helpers::TextHelper
  concerned_with :receive

  ANSWER_LINE = '-----------------------------==-----------------------------'

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
    from          invitation.user.email
    subject       "#{invitation.user.name} shared [#{invitation.project.name}] with you"
    body          :referral => invitation.user, :project => invitation.project, :invitation => invitation
  end
  
  def group_invitation(invitation)
    defaults
    recipients    invitation.email
    from          invitation.user.email
    subject       "#{invitation.user.name} shared [#{invitation.group.name}] with you"
    body          :referral => invitation.user, :group => invitation.group, :invitation => invitation
  end

  def signup_invitation(invitation)
    defaults
    recipients    invitation.email
    subject       "#{invitation.user.name} shared [#{invitation.project.name}] with you"
    body          :referral => invitation.user, :project => invitation.project, :invitation => invitation
  end

  def signup_group_invitation(invitation)
    defaults
    recipients    invitation.email
    subject       "#{invitation.user.name} shared [#{invitation.group.name}] with you"
    body          :referral => invitation.user, :group => invitation.group, :invitation => invitation
  end

  def notify_comment(user, project, comment)
    defaults
    recipients    user.email
    from          comment.user.email
    if APP_CONFIG['allow_incoming_email']
      reply_to      from_address("#{project.permalink}")
    end
    subject       "[#{project.permalink}] #{truncate(comment.body, :length => 20)}"
    body          :project => project, :comment => comment, :recipient => user
  end

  def notify_conversation(user, project, conversation)
    defaults
    recipients    user.email
    from          conversation.comments.first.user.email
    if APP_CONFIG['allow_incoming_email']
      reply_to      from_address("#{project.permalink}+conversation+#{conversation.id}")
    end
    subject       "[#{project.permalink}] #{conversation.name}"
    body          :project => project, :conversation => conversation, :recipient => user
  end

  def notify_task(user, project, task)
    defaults
    recipients    user.email
    from          task.comments.first.user.email
    if APP_CONFIG['allow_incoming_email']
      reply_to      from_address("#{project.permalink}+task+#{task.id}")
    end
    subject       "[#{project.permalink}] #{task.name}"
    body          :project => project, :task => task, :task_list => task.task_list, :recipient => user
  end

  def notify_task_list(user, project, task_list)
    defaults
    recipients    user.email
    from          task_list.comments.first.user.email
    if APP_CONFIG['allow_incoming_email']
      reply_to      from_address("#{project.permalink}+task_list+#{task_list.id}")
    end
    subject       "[#{project.permalink}] #{task_list.name}"
    body          :project => project, :task_list => task_list, :recipient => user
  end

  def daily_task_reminder(user, tasks)
    defaults
    recipients    user.email
    subject       I18n.t("users.daily_task_reminder_email.daily_task_reminder")
    body          :user => user, :tasks => tasks
  end

  def self.send_with_language(template, language, *args)
    meth = "deliver_#{template.to_s}"
    old_locale = I18n.locale
    I18n.locale = language
    send(meth, *args)
    I18n.locale = old_locale
  end

  private

    def from_address(recipient = "no-reply", name = "Teambox")
      if APP_CONFIG['outgoing']['safe_from']
        "#{recipient}@#{APP_CONFIG['outgoing']['from']}"
      else
        "#{name} <#{recipient}@#{APP_CONFIG['outgoing']['from']}>"
      end
    end

    def defaults
      content_type  'text/html'
      sent_on       Time.now
      from          from_address
    end
end
