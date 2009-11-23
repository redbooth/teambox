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

class Emailer

  REPLY_REGEX = /(Re: |RE: |Fwd: |FWD: )/

  # for attachment in email.attachments
  
  def receive(email)
    process email
    get_target
    
    case @type
    when :conversation
      if @target
        puts "Posting to conversation #{@target.id} '#{@subject}'"
        post_to @target        
      else
        puts "Creating conversation '#{@subject}'"
        create_conversation        
      end
    else
      raise "Invalid target type"
    end    
  end
  
  private
  
  def process(email)
    raise "Invalid To field"   unless email.to   and email.to.first
    raise "Invalid From field" unless email.from and email.from.first

    @to       = email.to.first.split('@').first.downcase
    @body     = (email.multipart? ? email.parts.first.body : email.body).strip
    @user     = User.find_by_email email.from.first
    @subject  = email.subject.gsub(REPLY_REGEX, "")
    @project  = Project.find_by_permalink @to.split('+').first
    
    raise "Invalid project '#{@to}'" unless @project
    raise "Invalid user '#{email.from.first}'" unless @user
    raise "Invalid body" unless @body
    
    raise "User does not belong to project" unless @user.projects.include? @project
    
    puts "#{@user.name} <#{@user.email}> sent '#{@subject}' to #{@project.permalink}"
  end
  
  # Decides which kind of object we'll be posting to (Conversation, Task, Task List..)
  # and finds it if appliable.
  def get_target
    extra_params = @to.split('+')

    case extra_params.count
      when 1 # projectname@mailserver.com
        @type = :conversation
        @target = Conversation.find_by_name_and_project_id(@subject, @project.id)
      when 2 # projectname+targetclass@mailserver.com
        case extra_params.second
        when :conversation
          @type = :conversation
          @target = Conversation.find_by_name_and_project_id(@subject, @project.id)
        else
          raise "Invalid target class"
        end
      when 3 # projectname+targetclass+id@mailserver.com
        case extra_params.second
        when :conversation
          @type = :conversation
          @target = Conversation.find_by_id_and_project_id(extra_params.third, @project.id)
        else
          raise "Invalid target class"
        end
      else
        raise "Invalid recipient: '#{@to}'"
    end
  end
  
  def post_to(target)
    comment = @project.new_comment(@user, target, :name => @subject)
    comment.body = @body
    comment.save!
  end
  
  def create_conversation
    conversation = @project.new_conversation(@user, :name => @subject)
    conversation.body = @body
    conversation.save!
  end

end