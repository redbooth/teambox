require 'net/pop'
require 'net/imap'
require 'net/http'
require 'action_view/helpers/text_helper'

# Receives email
#
# proj-permalink@app.server.com
#   → new conversation with Subject as a title and Body as a comment
#
# proj-permalink+conversation@app.server.com
#   → find or create conversation with Subject as a title and Body as a comment
#
# proj-permalink+task@app.server.com
#   → new task with Subject (or the Body if not present) as title
#
# proj-permalink+conversation+5@app.server.com
#   → new comment for the conversation #5
#
# proj-permalink+task+12@app.server.com
#   → new comment for the task #12
#
# Invalid or malformed emails will be ignored and sometimes bounced to the receiver.

module Emailer::Incoming
  include ActionView::Helpers::TextHelper
  ACTION_MATCH = /^\s*#(\w+)/

  def self.fetch(settings)
    type = settings[:type].to_s.downcase
    send("fetch_#{type}", settings)
  rescue SocketError
    settings_out = settings.merge(:password => '*' * settings[:password].to_s.length)
    Rails.logger.error "Error connecting to mail server with settings:\n  #{settings_out.inspect}"
    raise
  end

  def self.fetch_pop(settings)
    Net::POP3.start(settings[:address], settings[:port], settings[:user_name], settings[:password]) do |pop|
      pop.mails.each do |email|
        begin
          Emailer.receive(email.pop)
          email.delete
        rescue Exception
          Rails.logger.error "Error receiving email at #{Time.now}: #{$!}"
        end
      end
    end
  end
  
  def self.fetch_imap(settings)
    imap = Net::IMAP.new(settings[:address], settings[:port], true)
    imap.login(settings[:user_name], settings[:password])
    imap.select('Inbox')

    imap.uid_search(["NOT", "DELETED"]).each do |uid|
      source = imap.uid_fetch(uid, ['RFC822']).first.attr['RFC822']

      begin
        Emailer.receive(source)
      rescue Exception
        Rails.logger.error "Error receiving email at #{Time.now}: #{$!}"
      end

      imap.uid_copy(uid, "[Gmail]/All Mail")
      imap.uid_store(uid, "+FLAGS", [:Deleted])
    end

    imap.expunge
    imap.logout
    imap.disconnect
  end

  REPLY_REGEX = /(re|fwd):/i

  # Instance method invoked by class method of the same name.
  # Receives a parsed and decoded TMail::Mail object.
  def receive(email)
    email = ParamsMail.new(email) if Hash === email

    # TODO: ease a bit on the ivars pls
    process_incoming email

    unless @project.organization.omit_email_processing?

      get_target email

      case @type
      when :project
        create_conversation
      when :conversation
        if @target then post_to(@target)
        else create_conversation
        end
      when :task
        unless @target
          @target = create_task
        end

        get_action
        @body = extract_action
        post_to(@target)
      end
      
    end
  end

  private

  # Sendgrid params to act as TMail::Mail
  class ParamsMail
    def initialize(params)
      @params = params
      @from = @to = @cc = nil
      @attachments = nil
      @charsets = JSON.parse(@params[:charsets] || '{}')
    end
    
    %w[from to cc].each do |field|
      class_eval <<-CODE
        def #{field}
          @#{field} ||= field_to_addr(:#{field})
        end
      CODE
    end
    
    def body
      @body ||= field_to_utf8(:text)
    end
    
    def subject
      @params[:subject]
    end
    
    def attachments
      @attachments ||= begin
        files = []
        @params[:attachments].to_i.times { |i|
          files << @params[:"attachment#{i+1}"]
        }
        files
      end
    end
    
    private
    
    def field_to_addr(field)
      value = @params[field.to_sym]
      return if value.blank?
      # RAILS3 report bug, this doesn't parse with a newline char at the end
      header = Mail::Field.new(field.to_s, value.strip)
      header.addrs.map &:address
    end
    
    def field_to_utf8(field)
      value = @params[field.to_sym]
      return value if value.blank?
      
      charset = @charsets[field.to_s]
      if charset and charset.downcase != 'utf-8'
        begin
          value = Iconv.iconv('utf-8', charset, value).first
        rescue Iconv::IllegalSequence, Iconv::InvalidEncoding, Errno::EINVAL
          # do nothing
        end
      end
      return value
    end
  end
  
  class MissingInfo < ArgumentError; end
  class Error < StandardError
    attr_accessor :mail
    
    def initialize(mail, message)
      super(message)
      @mail = mail
    end
    
    def sender?
      mail.from.present?
    end
  end
  
  class UserNotFoundError < Error; end
  class NotProjectMemberError < Error; end
  class ProjectNotFoundError < Error; end
  class TargetNotFoundError < Error; end

  # accepts params in Sendgrid's format: http://wiki.sendgrid.com/doku.php?id=parse_api
  def process_incoming(email)
    raise MissingInfo, "Invalid mail body" if email.body.blank?
    
    from = Array(email.from).first
    raise MissingInfo, "Invalid From field" if from.nil?
    
    configured_domain = Teambox.config.smtp_settings[:domain]
    destinations = Array(email.to) + Array(email.cc)
    target = destinations.detect { |a| a.include? configured_domain }
    raise MissingInfo, "Invalid To fields" if target.nil?

    @to = target.split('@').first.downcase
    @project = Project.find_by_permalink @to.split('+').first
    raise ProjectNotFoundError.new(email, "Invalid project '#{@to}'") unless @project
    
    @user = User.find_by_email from
    raise UserNotFoundError.new(email, "Invalid user '#{email.from.first}'") unless @user
    raise NotProjectMemberError.new(email, "User does not belong to project") unless @user.projects.include? @project

    # Check if organization wants to receive emails
    

    # Get the body in multipart emails as well
    if email.respond_to? :parts
      parts = email.parts.select{|p| p.content_type.include?('text/')}
      @body = parts.any? ? parts.collect(&:decoded).join("\n") : email.body
    else
      @body = email.body
    end
    #strip any remaining html tags (after strip_responses) from the body
    @body    = strip_responses(@body).strip_tags.to_s.strip
    @subject = email.subject.to_s.gsub(REPLY_REGEX, "").strip
    @files   = email.attachments || []
    
    Rails.logger.info "#{@user.name} <#{@user.email}> sent '#{@subject}' to #{@to}"
  end
  
  # Removes 'On ... bla bla wrote line'
  # Splits emails on answer line and takes top half
  # Gmail adds <div class='email' to indicate where real message begins
  # so we split on that too and again take top half
  # finally strip any whitespace
  def strip_responses(body)
    # For GMail. Matches "On 19 August 2010 13:48, User <proj+conversation+22245@app.teambox.com<proj%2Bconversation%2B22245@app.teambox.com>> wrote:"
    body.to_s.strip.
      gsub(/\n[^\r\n]*\d{2,4}.*\+.*\d@app.teambox.com.*:.*\z/m, '').
      split(Emailer::ANSWER_LINE).first.
      split("<div class='email'").first.
      strip
  end
  
  # Decides which kind of object we'll be posting to (Conversation, Task, Task List..)
  # and finds it if appliable.
  def get_target(email)
    # projectname+targetclass+id@mailserver.com
    permalink, klass, object_id = @to.split('+')
    
    begin
      @type = klass ? klass.singularize.to_sym : :project

      if object_id
        @target = @project.send(@type.to_s.pluralize).find(object_id)
      elsif klass
        case @type
        when :conversation
          @target = @project.conversations.find_by_name(@subject)
        when :task then # do nothing
        else
          raise ArgumentError, "unknown type: #{@type}"
        end
      else
        @target = @project
      end
    rescue ArgumentError, NoMethodError, ActiveRecord::RecordNotFound => ex
      Rails.logger.debug "[Incoming email] captured #{ex.class}: #{ex.message}"
      raise TargetNotFoundError.new(email, "couldn't process target #{@to}")
    end
  end
  
  # Determines the #action
  # The commands are #resolve / #resolved, #username, #reject / #rejected and #hold.
  def get_action
    if @body =~ ACTION_MATCH
      tag = $1.downcase
      
      @target_action = case tag
      when 'open', 'reopen'      then :open
      when 'resolve', 'resolved' then :resolved
      when 'reject', 'rejected'  then :rejected
      when 'hold'                then :hold
      else
        if person = @target.project.people.by_login(tag).first
          @target_person = person
          :assign
        end
      end
    end
  end
  
  def extract_action
    get_action
    @body.sub(ACTION_MATCH, '').strip
  end
  
  def post_to(target)
    Rails.logger.info "Posting to #{target.class.to_s} #{target.id} '#{@subject}'"

    attributes = @files.collect {|f| { :asset => f }}
    if target.is_a? Task
      target.updating_user = @user
      target.comments_attributes = [{:body => @body, :uploads_attributes => attributes}]
      
      case @target_action
      when :assign
        target.status_name = :open
        target.assigned = @target_person
      when Symbol
        target.status_name = @target_action
      end
      
      target.save!
    else
      comment = target.comments.new_by_user(@user, :body => @body, :uploads_attributes => attributes)
      comment.save!
    end
  end
  
  def create_conversation
    Rails.logger.info "Creating conversation '#{@subject}'"

    attributes = @files.collect {|f| { :asset => f }}

    conversation = @project.conversations.new_by_user(@user, :comments_attributes => [{:body => @body, :uploads_attributes => attributes}])

    if @subject.blank?
      conversation.simple = true
    else
      conversation.name = @subject
    end
    
    conversation.save!
  end
  
  def create_task
    raise "Subject and body cannot be blank when creating task from email" if @subject.blank? && @body.blank?
    Rails.logger.info "Creating task '#{@subject}'"
    
    task_list_name = Teambox.config.incoming_email_settings[:inbox_task_list] || "Inbox"

    task_list = @project.task_lists.find_by_name(task_list_name) || @project.task_lists.create! do |task_list|
      task_list.user = @user
      task_list.name = task_list_name
    end
    
    task = task_list.tasks.create! do |task|
      task.name = @subject.blank? ? truncate(@body, :length => 255) : @subject
      task.project = @project
      task.user = @user
    end
  end

end
