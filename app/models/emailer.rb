class Emailer < ActionMailer::Base
  include ActionController::UrlWriter # Allows us to generate URLs
  include ActionView::Helpers::TextHelper
  include Emailer::Incoming
  
  # can't use regular `receive` class method since it deals with Mail objects
  def self.receive_params(params)
    new.receive(params)
  end

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
  
  def notify_export(data)
    defaults
    
    error = !data.exported?
    recipients    data.user.email
    subject       error ? I18n.t('emailer.teamboxdata.export_failed') : I18n.t('emailer.teamboxdata.exported')
    body          :data => data, :user => data.user, :error => error
  end
  
  def notify_import(data)
    defaults
    
    error = !data.imported?
    recipients    data.user.email
    subject       error ? I18n.t('emailer.teamboxdata.import_failed') : I18n.t('emailer.teamboxdata.imported')
    body          :data => data, :user => data.user, :error => error
  end

  def notify_conversation(user, project, conversation)
    title = conversation.name.blank? ? 
              truncate(conversation.comments.first(:order => 'id ASC').body.strip) :
              conversation.name
    defaults
    recipients    user.email
    from_reply_to "#{project.permalink}+conversation+#{conversation.id}", conversation.comments.first.user
    subject       "[#{project.permalink}] #{title}"
    body          :project => project, :conversation => conversation, :recipient => user
  end

  def notify_task(user, project, task)
    defaults
    recipients    user.email
    from_reply_to "#{project.permalink}+task+#{task.id}", task.comments.first.user
    subject       "[#{project.permalink}] #{task.name}"
    body          :project => project, :task => task, :task_list => task.task_list, :recipient => user
  end

  def project_membership_notification(invitation)
    defaults
    recipients    invitation.invited_user.email
    from_reply_to "#{invitation.project.permalink}", invitation.user
    subject       I18n.t("emailer.project_membership_notification.subject", :user => invitation.user.name, :project => invitation.project.name)
    body          :project => invitation.project, :recipient => invitation.invited_user
  end

  def daily_task_reminder(user)
    tasks = user.tasks_for_daily_reminder_email
    
    defaults
    recipients    user.email
    subject       I18n.t("users.daily_task_reminder_email.daily_task_reminder")
    body          :user => user, :tasks => tasks
  end
  
  def bounce_message(exception)
    defaults
    pretty_exception = exception.class.name.underscore.split('/').last
    info_url = 'http://help.teambox.com/faqs/advanced-features/email'
    
    recipients    exception.mail.from
    subject       I18n.t("emailer.bounce.subject")
    body          I18n.t("emailer.bounce.#{pretty_exception}") + "\n\n---\n" +
                  I18n.t("emailer.bounce.not_delivered", :link => info_url)
  end

  def self.send_with_language(template, language, *args)
    meth = "deliver_#{template.to_s}"
    old_locale = I18n.locale
    I18n.locale = language
    send(meth, *args)
    I18n.locale = old_locale
  end

  # requires data from rake db:seed
  class Preview < MailView
    def notify_task
      task = Task.find_by_name "Contact area businesses for banner exchange"
      Emailer.create_notify_task(task.user, task.project, task)
    end
    
    def notify_conversation
      conversation = Conversation.find_by_name "Seth Godin's 'What matters now'"
      Emailer.create_notify_conversation(conversation.user, conversation.project, conversation)
    end

    def daily_task_reminder
      user = User.first
      Emailer.create_daily_task_reminder(user)
    end

    def signup_invitation
      invitation = Invitation.new do |i|
        i.email = 'test@teambox.com'
        i.token = ActiveSupport::SecureRandom.hex(20)
        i.user = User.first
        i.project = Project.first
      end
      Emailer.create_signup_invitation(invitation)
    end

    def reset_password
      user = User.first
      Emailer.create_reset_password(user)
    end

    def forgot_password
      password_reset = ResetPassword.new do |passwd|
        passwd.user = User.first
        passwd.reset_code = ActiveSupport::SecureRandom.hex(20)
      end
      Emailer.create_forgot_password(password_reset)
    end

    def project_membership_notification
      invitation = Invitation.new do |i|
        i.user = User.first
        i.invited_user = User.last
        i.project = Project.first
      end
      Emailer.create_project_membership_notification(invitation)
    end

    def project_invitation
      invitation = Invitation.new do |i|
        i.token = ActiveSupport::SecureRandom.hex(20)
        i.user = User.first
        i.invited_user = User.last
        i.project = Project.first
      end
      Emailer.create_project_invitation(invitation)
    end

    def confirm_email
      user = User.first
      Emailer.create_confirm_email(user)
    end
  end

  private

    def from_reply_to(reply_identifier, user)
      from from_user(reply_identifier, user)
      reply_address = from_user(reply_identifier, nil)
      reply_to reply_address unless reply_address.starts_with?("no-reply")
    end
    
    def from_user(reply_identifier, user)
      unless Teambox.config.allow_incoming_email and reply_identifier
        reply_identifier = "no-reply"
      end
      
      from_address(reply_identifier, user.try(:name))
    end

    def from_address(recipient = "no-reply", name = "Teambox")
      domain = Teambox.config.smtp_settings[:domain]
      address = "#{recipient}@#{domain}"
      
      if name.blank? or Teambox.config.smtp_settings[:safe_from]
        address
      else
        %("#{name}" <#{address}>)
      end
    end

    def defaults
      content_type  'text/html'
      sent_on       Time.now
      from          from_address
    end
end
