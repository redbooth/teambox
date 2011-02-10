class Emailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  include Emailer::Incoming

  helper :application

  ANSWER_LINE = '-----------------------------==-----------------------------'

  class << self

    def emailer_defaults
      {
      :content_type => 'text/html',
      # :sent_on => Time.now,
      :from => from_address
      }
    end

    def send_email(template, *args)
      send_with_language(template, :en, *args)
    end

    def send_with_language(template, language, *args)
      old_locale = I18n.locale
      I18n.locale = language
      begin
        send(template, *args).deliver
      ensure
        I18n.locale = old_locale
      end
    end

    # can't use regular `receive` class method since it deals with Mail objects
    def receive_params(params)
      new.receive(params)
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
  end

  default emailer_defaults


  def confirm_email(user_id)
    @user = User.find(user_id)
    @login_link = confirm_email_user_url(@user, :token => @user.login_token)

    mail(
      :to         => @user.email,
      :subject => I18n.t("emailer.confirm.subject")
    )
  end

  def reset_password(user_id)
    @user = User.find(user_id)
    mail(
      :to         => @user.email,
      :subject    => I18n.t("emailer.reset_password.subject")
    )
  end

  def forgot_password(reset_password_id)
    reset_password = ResetPassword.find(reset_password_id)
    @user = reset_password.user
    @url  = reset_password_url(reset_password.reset_code)
    mail(
      :to         =>   reset_password.user.email,
      :subject    =>   I18n.t("emailer.forgot_password.subject")
    )
  end

  def project_invitation(invitation_id)
    @invitation = Invitation.find(invitation_id)
    @referral   = @invitation.user
    @project    = @invitation.project
    mail(
      :to         => @invitation.email,
      :from       => self.class.from_user(nil, @invitation.user),
      :subject    => I18n.t("emailer.invitation.subject", 
                            :user => @invitation.user.name, 
                            :project => @invitation.project.name)
    )
  end

  def signup_invitation(invitation_id)
    @invitation = Invitation.find(invitation_id)
    @referral   = @invitation.user
    @project    = @invitation.project
    mail(
      :to         => @invitation.email,
      :subject    => I18n.t("emailer.invitation.subject", 
                            :user    => @invitation.user.name, 
                            :project => @invitation.project.name)
    )
  end

  def notify_export(data_id)
    @data  = TeamboxData.find(data_id)
    @user  = @data.user
    @error = !@data.exported?
    mail(
      :to         => @data.user.email,
      :subject    => @error ? I18n.t('emailer.teamboxdata.export_failed') : I18n.t('emailer.teamboxdata.exported')
    )
  end

  def notify_import(data_id)
    @data  = TeamboxData.find(data_id)
    @user  = @data.user
    @error = !@data.imported?
    mail(
      :to         => @data.user.email,
      :subject    => @error ? I18n.t('emailer.teamboxdata.import_failed') : I18n.t('emailer.teamboxdata.imported')
    )
  end

  def notify_conversation(user_id, project_id, conversation_id)
    @project      = Project.find(project_id)
    @conversation = Conversation.find(conversation_id)
    @recipient    = User.find(user_id)
    @organization = @project.organization

    title         = @conversation.name.blank? ? 
                    truncate(@conversation.comments.first(:order => 'id ASC').body.strip) :
                    @conversation.name

    mail({
      :to            => @recipient.email,
      :subject       => "[#{@project.permalink}] #{title}"
    }.merge(
      from_reply_to "#{@project.permalink}+conversation+#{@conversation.id}", @conversation.comments.first.user
    ))
  end

  def notify_task(user_id, project_id, task_id)
    @project      = Project.find(project_id)
    @task         = Task.find(task_id)
    @task_list    = @task.task_list
    @recipient    = User.find(user_id)
    @organization = @task.project.organization
    mail({
      :to            => @recipient.email,
      :subject       => "[#{@project.permalink}] #{@task.name}#{task_description(@task)}"
    }.merge(
      from_reply_to "#{@project.permalink}+task+#{@task.id}", @task.comments.first.user
    ))
  end

  def project_membership_notification(invitation_id)
    @invitation = Invitation.find_with_deleted(invitation_id)
    @project    = @invitation.project
    @recipient  = @invitation.invited_user
    mail({
      :to            => @invitation.invited_user.email,
      :subject       => I18n.t("emailer.project_membership_notification.subject", 
                               :user => @invitation.user.name, 
                               :project => @invitation.project.name)
    }.merge(
      from_reply_to "#{@invitation.project.permalink}", @invitation.user
    ))
  end

  def daily_task_reminder(user_id)
    @user  = User.find(user_id)
    @tasks = @user.tasks_for_daily_reminder_email
    mail(
      :to         => @user.email,
      :subject    => I18n.t("users.daily_task_reminder_email.daily_task_reminder")
    ) 
  end

  def bounce_message(exception_mail, pretty_exception)
    info_url = 'http://help.teambox.com/faqs/advanced-features/email'

    mail(
      :to         => exception_mail,
      :subject    => I18n.t("emailer.bounce.subject"),
      :body       => I18n.t("emailer.bounce.#{pretty_exception}") + "\n\n---\n" +
                     I18n.t("emailer.bounce.not_delivered", :link => info_url)
    )
  end

  def simple_message(user_id, subject, message)
    @user = User.find(user_id)
    @message = message
    mail({
      :to => @user.email,
      :subject => subject
    })
  end

  # requires data from rake db:seed
  class Preview < MailView
    def notify_task
      task = Task.find_by_name "Contact area businesses for banner exchange"
      ::Emailer.notify_task(task.user.id, task.project.id, task.id)
    end

    def notify_conversation
      conversation = Conversation.find_by_name "Seth Godin's 'What matters now'"
      ::Emailer.notify_conversation(conversation.user.id, conversation.project.id, conversation.id)
    end

    def daily_task_reminder
      user = User.find_by_login 'frank'
      ::Emailer.daily_task_reminder(user.id)
    end

    def signup_invitation
      invitation = Invitation.new do |i|
        i.email = 'test@teambox.com'
        i.token = ActiveSupport::SecureRandom.hex(20)
        i.user = User.first
        i.project = Project.first
      end
      invitation.save!(false)
      ::Emailer.signup_invitation(invitation.id)
    end

    def reset_password
      user = User.first
      ::Emailer.reset_password(user.id)
    end

    def forgot_password
      password_reset = ResetPassword.create! do |passwd|
        passwd.email = "reset#{ActiveSupport::SecureRandom.hex(20)}@example.com"
        passwd.user = User.first
        passwd.reset_code = ActiveSupport::SecureRandom.hex(20)
      end
      ::Emailer.forgot_password(password_reset.id)
    end

    def project_membership_notification
      invitation = Invitation.new do |i|
        i.user = User.first
        i.invited_user = User.last
        i.project = Project.first
      end
      invitation.save!(false)
      ::Emailer.project_membership_notification(invitation.id)
    end

    def project_invitation
      invitation = Invitation.new do |i|
        i.token = ActiveSupport::SecureRandom.hex(20)
        i.user = User.first
        i.invited_user = User.last
        i.project = Project.first
      end
      invitation.is_silent = true
      invitation.save!(false)
      ::Emailer.project_invitation(invitation.id)
    end

    def confirm_email
      user = User.first
      ::Emailer.confirm_email(user.id)
    end
  end

  private

    def from_reply_to(reply_identifier, user)
      reply_address = self.class.from_user(reply_identifier, nil)
      {:from => self.class.from_user(reply_identifier, user)}.merge(
        reply_address.starts_with?("no-reply") ? {} : {:reply_to => reply_address}
      )
    end

    def task_description(task)
      desc = task.comments.first.try(:body)
      task_description = truncate(desc ? desc : '', :length => 50)
      task_description.blank? ? '' : " - #{task_description}"
    end
end
