class User
  
  def find_or_create_example_project    
    @dagny = find_or_create_example_user('Dagny Taggart')
    @hank  = find_or_create_example_user('Hank Rearden')
    @ellis = find_or_create_example_user('Ellis Wyatt')

    remember_notification_settings
    disable_all_notifications

    @project = self.projects.find_by_name("John Galt Line")

    unless @project
      @project = self.projects.new(:name => 'John Galt Line', :user_id => id )
      @project.save!
      
      [@dagny, @hank, @ellis].each { |u| @project.add_user(u) }

      example_comment(@project, @dagny, "Hey guys, I'm setting up a project on Teambox to build the John Galt line. Hope it helps!")
      example_comment(@project, @ellis, "Cool, Dagny. Let's learn how to use this.")
      example_comment(@project, @hank,  "@ellis, you'll get a hold of it in no time. My guys at the coal and steel places use it to work closely in teams.")
      example_comment(@project, @dagny, "The way I use it is creating a **Project** for each event, department or project we have. Then I *invite* all the people concerned with it, so they can post and receive updates.\n\nProjects have:\n\n* Conversations\n* Task lists\n* Pages\n* Files")
      example_comment(@project, @hank,  "I like to use the project **wall** to leave interesting links that don't require much attention.\n\nEmail is too intrusive, so the wall is the perfect place to leave comments and advice.\n\nhttp://www.teambox.com")
      example_comment(@project, @dagny, "You can also format your text using [Markdown](http://daringfireball.net/projects/markdown/).")
      example_comment(@project, @ellis, "Very nice! I also noticed I can post files to a project wall. I can use this to call attention on images or quick ideas.")
      example_comment(@project, @ellis, "I'm going to invite #{name} to the project, too.\nHey, @#{login}, read below to learn how Teambox works! Also take a look at \"Conversations\":#{project_conversations_path(@project)}, \"Task lists\":#{project_task_lists_path(@project)}, \"Pages\":#{project_pages_path(@project)} and \"Files\":#{project_uploads_path(@project)} to learn more about how each section works.")
      example_comment(@project, @dagny, "Welcome, @#{login}! This is the project wall, try posting a comment with the box on top. You can also attach files!\nIn this page you will find updated to your conversations, tasks and pages, so taking a look here will let you know what's new in your project.")

      @project.activities.select { |a| a.target.is_a? Person }.each { |a| a.delete }
    end
    
    restore_notification_settings
    
    @project    
  end
  
  protected
    def remember_notification_settings
      @remember_notify_mentions      = self.notify_mentions
      @remember_notify_conversations = self.notify_conversations
      @remember_notify_task_lists    = self.notify_task_lists
      @remember_notify_tasks         = self.notify_tasks      
    end
    
    def restore_notification_settings
      self.notify_mentions      = @remember_notify_mentions
      self.notify_conversations = @remember_notify_conversations
      self.notify_task_lists    = @remember_notify_task_lists
      self.notify_tasks         = @remember_notify_tasks      
    end
    
    def disable_all_notifications
      self.notify_mentions      = false
      self.notify_conversations = false
      self.notify_task_lists    = false
      self.notify_tasks         = false
      self.save!
    end

    def example_comment(target, user, body)
      comment = target.comments.new
      comment.target = target
      comment.user = user
      comment.body = body
      comment.created_at = autogen_created_at
      comment.save!
    end
    
    def example_conversation(project, user, name, body)
      conversation = project.conversations.new
      conversation.name = name
      conversation.body = body
      conversation.user = user
      conversation.created_at = autogen_created_at
      conversation.save!
    end
  
    def find_or_create_example_user(name)
      first_name, last_name = name.split
      login = first_name
      email = "#{login}@teambox.com"
      if user = User.find_by_login(login)
        user
      else
        pass = ActiveSupport::SecureRandom.hex(10)
        user = User.new(
          :login => login,
          :email => email,
          :first_name => first_name,
          :last_name => last_name,
          :password => pass,
          :password_confirmation => pass)
        user.notify_mentions = false
        user.notify_conversations = false
        user.notify_task_lists = false
        user.notify_tasks = false
        user.activate!
      end
    end
    
    def autogen_created_at
      @autogen_created_at ||= 2.days.ago
      @autogen_created_at += 25.minutes
    end
end