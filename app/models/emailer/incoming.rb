require 'net/pop'
require 'net/imap'
require 'net/http'

# Receives an email and performs the adequate action
#
# Emails can be sent to project@app.server.com or project+model+id@app.server.com
# Cases:
#
# keiretsu@app.server.com                  Will find or start a conversation with Subject as a title and Body as a comment
# keiretsu+conversation@app.server.com     Will find or start a conversation with Subject as a title and Body as a comment
# keiretsu+task@app.server.com             Will start a conversation with Subject (or the Body if not present) as title
# keiretsu+conversation+5@app.server.com   Will post a new comment in the conversation whose id is 5
# keiretsu+task+12@app.server.com          Will post a new comment in the task whose id is 12
#
# Invalid or malformed emails will be ignored
#

module Emailer::Incoming

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
        rescue Exception => e
          Rails.logger.error "Error receiving email at #{Time.now}: #{$!}"
          if e.message == "Exclude Auto Responder"
            email.delete
          end
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
    process email
    get_target
    get_action if @target.is_a?(Task)
    case @type
    when :project then create_conversation
    when :conversation then @target ? post_to(@target) : create_conversation
    when :task
      unless @target
        @target = create_task
        get_action
      end
      post_to(@target)
    else raise "Invalid target type"
    end
  end

  private
  
  # Sendgrid params to act as TMail::Mail
  class ParamsMail
    def initialize(params)
      @params = params
      @from = @to = @cc = nil
      @attachments = nil
    end
    
    %w[from to cc].each do |field|
      class_eval <<-CODE
        def #{field}
          @#{field} ||= field_to_addr(:#{field})
        end
      CODE
    end
    
    def body
      @params[:text]
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
      header = TMail::AddressHeader.new(field.to_s, value)
      header.addrs.map &:spec
    end
  end
  
  class MissingInfo < ArgumentError; end
  class IllegalMail < RuntimeError; end

  # accepts params in Sendgrid's format: http://wiki.sendgrid.com/doku.php?id=parse_api
  def process(email)
    email = ParamsMail.new(email) if Hash === email
    
    raise MissingInfo, "Invalid mail body" if email.body.blank?
    
    from = Array(email.from).first
    raise MissingInfo, "Invalid From field" if from.nil?
    
    configured_domain = Teambox.config.smtp_settings[:domain]
    destinations = Array(email.to) + Array(email.cc)
    target = destinations.detect { |a| a.include? configured_domain }
    raise MissingInfo, "Invalid To fields" if target.nil?

    @to = target.split('@').first.downcase
    @project = Project.find_by_permalink @to.split('+').first
    raise MissingInfo, "Invalid project '#{@to}'" unless @project
    
    @user = User.find_by_email! from
    if @user.nil? or not @user.projects.include? @project
      raise IllegalMail, "User does not belong to project"
    end
    
    @body    = strip_responses(email.body)
    @subject = email.subject.gsub(REPLY_REGEX, "").strip
    @files   = email.attachments || []
    
    Rails.logger.info "#{@user.name} <#{@user.email}> sent '#{@subject}' to #{@to}"
  end
  
  def strip_responses(body)
    # For GMail. Matches "On 19 August 2010 13:48, User <proj+conversation+22245@app.teambox.com<proj%2Bconversation%2B22245@app.teambox.com>> wrote:"
    body.strip.
      gsub(/\n[^\r\n]*\d{2,4}.*\+.*\d@app.teambox.com.*:.*\z/m, '').
      split(Emailer::ANSWER_LINE).first.
      split("<div class='email'").first.
      strip
  end
  
  # Decides which kind of object we'll be posting to (Conversation, Task, Task List..)
  # and finds it if appliable.
  def get_target
    extra_params = @to.split('+')

    case extra_params.size
      when 1 # projectname@mailserver.com
        @type = :project
        @target = @project
      when 2 # projectname+targetclass@mailserver.com
        case extra_params.second
        when 'conversation', 'conversations'
          @type = :conversation
          @target = Conversation.find_by_name_and_project_id(@subject, @project.id)
        when 'task', 'tasks'
          @type = :task
          @target = nil
        else
          raise "Invalid target class"
        end
      when 3 # projectname+targetclass+id@mailserver.com
        case extra_params.second
        when 'conversation'
          @type = :conversation
          @target = Conversation.find_by_id_and_project_id(extra_params.third, @project.id)
        when 'task_list'
          @type = :task_list
          @target = TaskList.find_by_id_and_project_id(extra_params.third, @project.id)
        when 'task'
          @type = :task
          @target = Task.find_by_id_and_project_id(extra_params.third, @project.id)          
        else
          raise "Invalid target class"
        end
      else
        raise "Invalid recipient: '#{@to}'"
    end
  end
  
  # Determines the #action
  # The commands are #resolve / #resolved, #username, #reject / #rejected and #hold.
  def get_action
    if @body =~ /^\s*#(\w+)/
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
    
    task_list = @project.task_lists.find_by_name("Uncategorized") || @project.task_lists.create! do |task_list|
      task_list.user = @user
      task_list.name = "Uncategorized"
    end
    
    task = task_list.tasks.create! do |task|
      task.name = @subject.blank? ? @body : @subject
      task.project = @project
      task.user = @user
    end
  end

end
