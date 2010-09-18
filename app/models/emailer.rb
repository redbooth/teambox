class Emailer < ActionMailer::Base
  include ActionController::UrlWriter # Allows us to generate URLs
  include ActionView::Helpers::TextHelper
  include Emailer::Incoming

  ANSWER_LINE = '-----------------------------==-----------------------------'

  def confirm_email(user)
    defaults
    recipients    user.email
    subject       I18n.t("emailer.confirm.subject")
    body          :user => user, :login_link => confirm_email_user_url(user, :token => user.login_token)
  end

  def reset_password(user)
    defaults
    recipients    user.email
    subject       I18n.t("emailer.reset_password.subject")
    body          :user => user
  end

  def forgot_password(reset_password)
    defaults
    recipients    reset_password.user.email
    subject       I18n.t("emailer.forgot_password.subject")
    body          :user => reset_password.user, :url => reset_password_url(reset_password.reset_code)
  end

  def project_invitation(invitation)
    defaults
    recipients    invitation.email
    from          from_user(nil, invitation.user)
    subject       I18n.t("emailer.invitation.subject", :user => invitation.user.name, :project => invitation.project.name)
    body          :referral => invitation.user, :project => invitation.project, :invitation => invitation
  end
  
  def signup_invitation(invitation)
    defaults
    recipients    invitation.email
    subject       I18n.t("emailer.invitation.subject", :user => invitation.user.name, :project => invitation.project.name)
    body          :referral => invitation.user, :project => invitation.project, :invitation => invitation
  end

  def notify_conversation(user, project, conversation)
    defaults
    recipients    user.email
    from          from_user("#{project.permalink}+conversation+#{conversation.id}", conversation.comments.first.user)
    subject       "[#{project.permalink}] #{conversation.name}"
    body          :project => project, :conversation => conversation, :recipient => user
  end

  def notify_task(user, project, task)
    defaults
    recipients    user.email
    from          from_user("#{project.permalink}+task+#{task.id}", task.comments.first.user)
    subject       "[#{project.permalink}] #{task.name}"
    body          :project => project, :task => task, :task_list => task.task_list, :recipient => user
  end

  def daily_task_reminder(user)
    tasks = user.tasks_for_daily_reminder_email
    
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

    def from_user(command, user)
      if APP_CONFIG['allow_incoming_email'] && command
        from_address(command, "#{user.first_name} #{user.last_name}")
      else
        from_address("no-reply", "#{user.first_name} #{user.last_name}")
      end
    end

    def from_address(recipient = "no-reply", name = "Teambox")
      domain = Teambox.config.smtp_settings[:domain]
      address = "#{recipient}@#{domain}"
      
      if Teambox.config.smtp_settings[:safe_from]
        address
      else
        "#{name} <#{address}>"
      end
    end

    def defaults
      content_type  'text/html'
      sent_on       Time.now
      from          from_address
    end
end
