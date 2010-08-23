class ApidocsController < ApplicationController

  skip_before_filter :login_required
  skip_before_filter :load_project

  layout 'apidocs'

  before_filter :load_example_data
  before_filter :load_api_routes, :only => [:routes,:model]
  
  DOCUMENTED_MODELS = %w{activity comment conversation divider invitation membership note organization page person project task_list task upload user}

  def index
  end

  def concepts
  end

  def routes
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
      @project.new_task(@apiman, task_list, {:name => name}).tap do |task|
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
      upload = ActionController::UploadedStringIO.new
      unless data.nil?
        upload.write(data)
        upload.seek(0)
        upload.original_path = file
      else
        upload.original_path = "%s/%s" % [ File.dirname(__FILE__), file ]
        upload.write(File.read(uploader.original_path))
        upload.seek(0)
      end

      upload.content_type = type
      upload
    end
    
    def example_upload(page, filename, content_type, content=nil)
      @project.uploads.new({:asset => mock_upload(filename, content_type, content)}).tap do |upload|
        upload.user = @apiman
        upload.created_at = autogen_created_at
        upload.save!
      end
    end
    
    def load_example_data
      @apiman = User.find_or_create_example_user('API Man', 'example_api_user')
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
          @organization.memberships.create!(:user_id => @apiman.id, :role => Membership::ROLES[:admin])
        end
        
        @project = @apiman.projects.new(:name => 'Teambox Api Example Project', :user_id => @apiman.id)
        @project.organization = @organization
        @project.save!
        
        example_comment(@project, @task, "Testing the API!")
        
        example_task_list("Things to do with the API")
        example_task(@project.task_lists.first, "Mobile App")
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
    end

    def load_api_routes
      @routes = ActionController::Routing::Routes.routes.select do |route|
        route.defaults[:controller].starts_with? 'api_v1'
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

end
