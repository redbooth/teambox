class ProjectsController < ApplicationController
  around_filter :set_time_zone, :only => [:index, :show]
  before_filter :load_projects, :only => [:index]
  before_filter :set_page_title
  before_filter :disallow_for_community, :only => [:new, :create]
  before_filter :load_pending_projects, :only => [:index, :show]
  
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |f|
      flash[:error] = t('common.not_allowed')
      f.any(:html, :m) { redirect_to projects_path }
      handle_api_error(f, @current_project)
    end
  end
  
  def index
    @new_conversation = Conversation.new(:simple => true)
    @activities = Activity.for_projects(@projects)
    @threads = @activities.threads.all(:include => [:project, :target])
    @last_activity = @threads.last

    respond_to do |f|
      f.html
      f.m     { redirect_to activities_path if request.path == '/' }
      f.rss   { render :layout  => false }
      f.xml   { render :xml     => @projects.to_xml }
      f.json  { render :as_json => @projects.to_xml }
      f.yaml  { render :as_yaml => @projects.to_xml }
      f.ics   { render :text    => Project.to_ical(@projects, params[:filter] == 'mine' ? current_user : nil, request.host, request.port) }
      f.print { render :layout  => 'print' }
    end
  end

  def show
    @activities = Activity.for_projects(@current_project)
    @threads = @activities.threads.all(:include => [:project, :target])
    @last_activity = @threads.last
    @recent_conversations = @current_project.conversations.not_simple.recent(4)
    @new_conversation = @current_project.conversations.new(:simple => true)

    respond_to do |f|
      f.any(:html, :m)
      f.rss   { render :layout  => false }
      f.xml   { render :xml     => @current_project.to_xml }
      f.json  { render :as_json => @current_project.to_xml }
      f.yaml  { render :as_yaml => @current_project.to_xml }
      f.ics   { render :text    => @current_project.to_ical(params[:filter] == 'mine' ? current_user : nil) }
      f.print { render :layout  => 'print' }
    end
  end

  def new
    authorize! :create_project, current_user
    @project = Project.new
    @project.build_organization
    
    respond_to do |f|
      f.any(:html, :m)
    end
  end

  def create
    @project = current_user.projects.new(params[:project])
    authorize! :create_project, current_user

    respond_to do |f|
      if @project.save
        redirect_path = redirect_to_invite_people? ? project_invite_people_path(@project) : @project

        f.html { redirect_to redirect_path }
        f.m { redirect_to @project }
      else
        flash.now[:error] = t('projects.new.invalid_project')
        f.any(:html, :m) { render :new }
      end
    end
  end

  def edit
    authorize! :update, @current_project
    @sub_action = params[:sub_action] || 'settings'
    
    respond_to do |f|
      f.any(:html, :m)
    end
  end
  
  def update
    authorize! :update, @current_project
    authorize!(:transfer, @current_project) if params[:sub_action] == 'ownership'
    @sub_action = params[:sub_action] || 'settings'
    @organization = @current_project.organization if @current_project.organization

    if @current_project.update_attributes(params[:project])
      flash.now[:success] = t('projects.edit.success')
    else
      flash.now[:error] = t('projects.edit.error')
    end
    
    respond_to do |f|
      f.any(:html, :m) { render :edit }
    end
  end
 
  # Gets called from Project#create
  def invite_people
  end

  # POST action for invite_people
  def send_invites
    authorize! :admin, @current_project
    @current_project.invite_users = params[:project][:invite_users]
    @current_project.invite_emails = params[:project][:invite_emails]
    @current_project.send_invitations!
    redirect_to @current_project
  end

  def transfer
    authorize! :transfer, @current_project
    
    # Grab new owner
    user_id = params[:project][:user_id] rescue nil
    person = @current_project.people.find_by_user_id(user_id)
    saved = false
    
    # Transfer!
    unless person.nil?
      saved = @current_project.transfer_to(person)
    end
    
    if saved
      respond_to do |f|
        flash[:notice] = I18n.t('projects.edit.transferred')
        f.html { redirect_to project_path(@current_project) }
        handle_api_success(f, @current_project)
      end
    else
      respond_to do |f|
        flash[:error] = I18n.t('projects.edit.invalid_transferred')
        f.html { redirect_to project_path(@current_project) }
        handle_api_error(f, @current_project)
      end
    end
  end

  def destroy
    authorize! :destroy, @current_project
    @current_project.destroy
    respond_to do |f|
      f.any(:html, :m) {
        flash[:success] = t('projects.edit.deleted')
        redirect_to projects_path
      }
    end
  end

  skip_before_filter :belongs_to_project?, :only => [:join]

  def join
    if @current_project.organization.is_admin?(current_user)
      @current_project.add_user(current_user, :role => Person::ROLES[:admin])
      flash[:success] = t('projects.join.welcome')
      redirect_to project_path(@current_project)
    elsif @current_project.public
      @current_project.add_user(current_user, :role => Person::ROLES[:commenter])
      flash[:success] = t('projects.join.welcome')
      redirect_to project_path(@current_project)
    else
      render :text => "You're not authorized to join this project"
    end
  end

  def list
    @people = current_user.people
    @roles = {  Person::ROLES[:observer] =>    t('roles.observer'),
                Person::ROLES[:commenter] =>   t('roles.commenter'),
                Person::ROLES[:participant] => t('roles.participant'),
                Person::ROLES[:admin] =>       t('roles.admin') }


    organization_ids = current_user.projects.sort {|a,b| a.name <=> b.name}.group_by(&:organization_id)
    @organizations = organization_ids.collect do |k,v|
      r = {}
      r[:organization] = Organization.find(k)
      r[:active_projects] = v.reject(&:archived)
      r[:archived_projects] = v.select(&:archived)
      r
    end.sort {|a,b| a[:organization].name <=> b[:organization].name}
  end

  protected
  
    def load_task_lists
      @task_lists = @current_project.task_lists.unarchived
    end
  
    def load_projects
      @projects = current_user.projects.unarchived
    end

    def load_pending_projects
      @pending_projects = @current_user.invitations.pending_projects
    end

    # For community (single organization) version, disallow creating more than one organization
    def disallow_for_community
      if @community_organization && @community_role.nil?
        render :text => "You're not authorized to create projects on this organization."
      end
    end

    def redirect_to_invite_people?
      Rails.env.cucumber? || Teambox.config.allow_outgoing_email?
    end

end
