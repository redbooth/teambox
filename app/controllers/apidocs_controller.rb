class ApidocsController < ApplicationController

  skip_before_filter :login_required
  skip_before_filter :load_project

  layout 'apidocs'

  before_filter :load_example_data
  before_filter :load_api_routes, :only => [:routes,:model]
  
  DOCUMENTED_MODELS = %w{activity app_link comment conversation divider invitation membership note organization search page person project task_list task upload user}

  def index
  end

  def concepts
  end
  
  def changes
  end

  def routes
  end
  
  def auth
  end

  def model
    @model = params[:model].downcase
    unless DOCUMENTED_MODELS.include? @model
      render :text => "Invalid model #{@model}"
      return
    end
  end

  protected
  
    def autogen_created_at
      @autogen_created_at ||= 2.days.ago
      @autogen_created_at += 25.minutes
    end

    def example_app_link(provider)
      @app_link ||= AppLink.find_by_provider_and_user_id(provider, @apiman.id)
      unless @app_link
        @app_link = @apiman.app_links.create! do |app_link|
          app_link.provider = provider || 'google'
          app_link.app_user_id = @apiman.login
          app_link.credentials = {'token' => '123456789', 'secret' => 'bla'}
          app_link.custom_attributes = {'custom' => 1}
          app_link.created_at = autogen_created_at
        end
      end
      @app_link
    end
    
    def example_comment(target, user, body)
      @project.new_comment(@apiman, target, {:body => body}).tap do |comment|
        comment.created_at = autogen_created_at
        comment.save!
      end
    end
    
    def example_task_list(name)
      @project.new_task_list(@apiman, {:name => name}).tap do |task_list|
        task_list.created_at = autogen_created_at
        task_list.save!
      end
    end
    
    def example_task(task_list, name)
      @project.new_task(@apiman, task_list, {
        :name => name, :comments_attributes => { 0 => { :body => 'modified....',
                                 :uploads_attributes => {
                                   0 => {
                                     :asset => mock_upload("templates.txt", 'text/plain', "my data")
                                   }
                                 },
                                 :google_docs_attributes => {
                                   0 => {
                                     :title => 'Some google doc',
                                     :document_id => 'x123456789',
                                     :document_type => 'document',
                                     :url => 'http://google.com/docs/x1234567',
                                     :edit_url => 'http://google.com/docs/x1234567/edit',
                                     :acl_url => 'http://google.com/docs/x1234567/acl'
                                   }
                                 }
                               }
                         }
      }).tap do |task|
        task.created_at = autogen_created_at
        task.save!
      end
    end
    
    def example_conversation(name, body)
      @project.new_conversation(@apiman, {:name => name}).tap do |conversation|
        conversation.body = body
        conversation.created_at = autogen_created_at
        conversation.save!
      end
    end
    
    def example_invite(email)
      @project.invitations.new({:user_or_email => email}).tap do |invitation|
        invitation.created_at = autogen_created_at
        invitation.user = @apiman
        invitation.save!
      end
    end
    
    def example_page(name, description)
      @project.new_page(@apiman, {:name => name, :description => description}).tap do |page|
        page.created_at = autogen_created_at
        page.save!
      end
    end
    
    def example_note(page, name, body)
      @note = page.build_note({:name => name, :body => body}).tap do |note|
        note.updated_by = @apiman
        note.created_at = autogen_created_at
        note.save!
      end
    end
    
    def example_divider(page, name)
      page.build_divider({:name => name}).tap do |divider|
        divider.updated_by = @apiman
        divider.created_at = autogen_created_at
        divider.save!
      end
    end
    
    def mock_upload(file, type = 'image/png', data=nil)
      file_path = data ? file : "%s/%s" % [ File.dirname(__FILE__), file ]
      tempfile = Tempfile.new(file_path)
      if data
        tempfile << data
      else
        tempfile << File.read(file_path)
      end
      ActionDispatch::Http::UploadedFile.new({ :type => type, :filename => file_path, :tempfile => tempfile })
    end
    
    def example_upload(page, filename, content_type, content=nil)
      @project.uploads.new({:asset => mock_upload(filename, content_type, content)}).tap do |upload|
        upload.user = @apiman
        upload.created_at = autogen_created_at
        upload.save!
      end
    end
    
    def load_example_data
      @apiman = find_or_create_example_user('API Man', 'example_api_user')
      @project = @apiman.projects.first
      @organization = @apiman.organizations.first

      if @project.nil?
        if @organization.nil?
          if Organization.count == 0
            render :text => 'In order to view the api documentation, you must first configure your app and build an organization.'
            return
          end
          @organization = Organization.new(:name => 'API Corp')
          @organization.is_example = true
          @organization.save!
          membership = @organization.memberships.build(:role => Membership::ROLES[:admin])
          membership.user_id = @apiman.id
          membership.save!
        end
        
        @project = @apiman.projects.new(:name => 'Teambox Api Example Project', :user_id => @apiman.id)
        @project.organization = @organization
        @project.save!
        
        example_comment(@project, @task, "Testing the API!")
        
        example_task_list("Things to do with the API")
        task = example_task(@project.task_lists.first, "Mobile App")
        example_comment(@project, @task, "Working on it")
        
        example_conversation("What to do with the API", "Anyone have any ideas?")
        
        example_invite("frodo@teambox.com")
        
        example_page("Random notes", "... of questionable value")
        example_note(@project.pages.first, "RailsConf", "TODO: check dates")
        example_divider(@project.pages.first, "Conferences")
        example_upload(@project.pages.first, 'semicolons.js', 'application/javascript', 'alert(\'WHAT?!\')')
      end
      
      @invitation = @project.invitations.first
      @membership = @organization.memberships.first
      @person = @project.people.first
      @user = @person.user
      @activity = @project.activities.first
      
      @page = @project.pages.first
      @note = @page.notes.first
      @divider = @page.dividers.first
      
      @upload = @project.uploads.first
      @conversation = @project.conversations.first
      
      @task_list = @project.task_lists.first
      @task = @task_list.tasks.first
      @comment = @project.comments.first
      @converted_comment = @project.tasks.first
      @app_link = example_app_link('twitter')
    end

    def load_api_routes
      @routes = ActionController::Routing::Routes.routes.select do |route|
        unless route.defaults[:controller].nil?
          route.defaults[:controller].starts_with? 'api_v1'
        else
          false
        end
      end.collect do |route|
        { :controller => route.defaults[:controller].split('/').second,
          :action => route.defaults[:action],
          :path => route.to_s.scan(/\/api.*?[(\s]/).first.chomp('('),
          :method => route.to_s.split(" ").first }
      end.sort_by { |route| route[:controller] }
      
      route_map = {}
      @consolidated_routes = @routes.map do |route|
        hash = "#{route[:controller]}_#{route[:action]}"
        if route_map.has_key? hash
          route_map[hash][:path] << route[:path]
          nil
        else
          base = route.clone
          base[:path] = [route[:path]]
          route_map[hash] = base
          base
        end
      end.compact
    end

    def find_or_create_example_user(name, login=nil)
      first_name, last_name = name.split
      login ||= first_name
      if user = User.find_by_login(login)
        user
      else
        pass = ActiveSupport::SecureRandom.hex(10)
        user = User.new(
          :login => login,
          :email => "#{login}@teambox.com",
          :first_name => first_name,
          :last_name => last_name,
          :password => pass,
          :password_confirmation => pass)

        user.notify_conversations = false
        user.notify_tasks = false
        user.activate!
      end
    end

end
