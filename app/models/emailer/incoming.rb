require 'net/pop'
require 'net/imap'
require 'net/http'
require_dependency 'emailer'
require_dependency 'user'
require_dependency 'person'
require_dependency 'project'
require_dependency 'conversation'
require_dependency 'task'
require_dependency 'task_list'
require_dependency 'comment'
require_dependency 'activity'
require_dependency 'upload'
require_dependency 'email'

# Receives an email and performs the adequate action
#
# Emails can be sent to project@app.server.com or project+model+id@app.server.com
# Cases:
#
# keiretsu@app.server.com                  Will post a new comment on the project's activity wall
# keiretsu+conversation@app.server.com     Will create a new conversation with Subject as a title and Body as a comment
# keiretsu+conversation+5@app.server.com   Will post a new comment in the conversation whose id is 5
# keiretsu+task+12@app.server.com          Will post a new comment in the task whose id is 12
#
# Invalid or malformed emails will be ignored
#
# TODO: Enhance mime and plain messages treatment
#       Parse HTML to Markdown
#       Strip the quoted text from email replies
#
module Emailer::Incoming

  def logger
    Rails.logger
  end

  def self.fetch(settings)
    type = settings[:type].to_s.downcase
    send("fetch_#{type}", settings)
  rescue SocketError
    settings_out = settings.merge(:password => '*' * settings[:password].to_s.length)
    logger.error "Error connecting to mail server with settings:\n  #{settings_out.inspect}"
    raise
  end

  def self.fetch_pop(settings)
    Net::POP3.start(settings[:address], settings[:port], settings[:user_name], settings[:password]) do |pop|
      pop.mails.each do |email|
        begin
          Emailer.receive(email.pop)
          email.delete
        rescue Exception
          logger.error "Error receiving email at #{Time.now}: #{$!}"
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
        logger.error "Error receiving email at #{Time.now}: #{$!}"
      end

      imap.uid_copy(uid, "[Gmail]/All Mail")
      imap.uid_store(uid, "+FLAGS", [:Deleted])
    end

    imap.expunge
    imap.logout
    imap.disconnect
  end

  REPLY_REGEX = /(re|fwd):/i

  def receive(email)
    process email
    get_target
    get_action if @target.is_a?(Task)

    case @type
    when :project then post_to(@target)
    when :conversation then @target ? post_to(@target) : create_conversation
    when :task then post_to(@target) if @target
    else raise "Invalid target type"
    end
  end

  private

  def process(email)
    destinations = Array(email.to) + Array(email.cc)
    raise "Invalid To fields"  unless destinations and destinations.first
    raise "Invalid From field" unless email.from   and email.from.first

    @to       = destinations.
                  select { |a| a.include? Teambox.config.smtp_settings[:domain] }.
                  first.split('@').first.downcase
    @body     = email.multipart? ? email.parts.first.body : email.body
    @body     = @body.split(Emailer::ANSWER_LINE).first.split("<div class='email'").first.strip
    @user     = User.find_by_email email.from.first
    @subject  = email.subject.gsub(REPLY_REGEX, "").strip
    @project  = Project.find_by_permalink @to.split('+').first
    
    raise "Invalid project '#{@to}'" unless @project
    raise "Invalid user '#{email.from.first}'" unless @user
    raise "Invalid body" unless @body
    
    raise "User does not belong to project" unless @user.projects.include? @project
    
    logger.info "#{@user.name} <#{@user.email}> sent '#{@subject}' to #{@to}"
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
        when 'conversation'
          @type = :conversation
          @target = Conversation.find_by_name_and_project_id(@subject, @project.id)
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
    tag = /^\s*#([a-zA-Z0-9_]*)/.match(@body.gsub(/\n/, ' '))
    tag = tag ? tag[1] : nil
    
    case tag
    when 'open', 'reopen'
      @target_action = :open
    when 'resolve', 'resolved'
      @target_action = :resolve
    when 'reject', 'rejected'
      @target_action = :reject
    when 'hold'
      @target_action = :hold
    else
      people = @target.project.people.reject{ |r| r.login != tag }
      unless people.empty?
        @target_action = :assign
        @target_person = people.first
      end
    end
  end
  
  def post_to(target)
    logger.info "Posting to #{target.class.to_s} #{target.id} '#{@subject}'"

    comment = @project.new_comment(@user, target, :name => @subject)
    comment.body = @body
    if target.class == Task
      target.previous_status = target.status
      target.previous_assigned_id = target.assigned_id
      comment.status = target.status
      
      case @target_action
      when :open
        comment.status = Task::STATUSES[:open]
        comment.assigned_id = @project.people.find_by_user_id(@user.id)
      when :resolve
        comment.status = Task::STATUSES[:resolved]
      when :reject
        comment.status = Task::STATUSES[:rejected]
      when :hold
        comment.status = Task::STATUSES[:hold]
      when :assign
        comment.status = Task::STATUSES[:open]
        comment.assigned_id = @target_person.id
      else
        comment.assigned_id = target.assigned_id
      end
      
      target.status = comment.status
      target.assigned_id = comment.assigned_id
    end
    comment.save!
  end
  
  def create_conversation
    logger.info "Creating conversation '#{@subject}'"
    conversation = @project.new_conversation(@user, :name => @subject)
    conversation.body = @body
    conversation.save!
  end

end

Emailer.send(:include, Emailer::Incoming)
