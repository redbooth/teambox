class ProjectsController < ApplicationController
  around_filter :set_time_zone, :only => [:index, :show]
  before_filter :load_projects, :only => [:index]
  before_filter :set_page_title
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = t('common.not_allowed')
    redirect_to root_path
  end
  
  def index
    @activities = Activity.for_projects(@projects)

    respond_to do |f|
      f.html  { redirect_to root_path }
      f.rss   { render :layout  => false }
      f.ics   { render :text    => Project.to_ical(@projects, params[:filter] == 'mine' ? current_user : nil, request.host, request.port) }
      f.print { render :layout  => 'print' }
    end
  end

  def show
    @activities = Activity.for_projects(@current_project)

    respond_to do |f|
      f.html  { redirect_to root_path }
      f.rss   { render :layout  => false }
      f.ics   { render :text    => @current_project.to_ical(params[:filter] == 'mine' ? current_user : nil) }
    end
  end

  def new
    authorize! :create_project, current_user
    @project = Project.new
    @project.build_organization
  end

  def create
    @project = current_user.projects.new(params[:project])
    authorize! :create_project, current_user

    respond_to do |f|
      if @project.save
        redirect_to redirect_to_invite_people? ? project_invite_people_path(@project) : @project
      else
        flash.now[:error] = t('projects.new.invalid_project')
      end
    end
  end

  def edit
    authorize! :update, @current_project
    @sub_action = params[:sub_action] || 'settings'
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
    
    render :edit
  end
 
  # Gets called from Project#create
  def invite_people
    @contacts = @current_project.organization.users_in_projects - [current_user]
  end

  # POST action for invite_people
  def send_invites
    authorize! :admin, @current_project
    @current_project.invite_users = params[:project][:invite_users]
    @current_project.invite_emails = params[:project][:invite_emails]
    @current_project.invitations_locale = params[:invitations_locale]
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
      flash[:notice] = I18n.t('projects.edit.transferred')
      redirect_to project_path(@current_project)
    else
      flash[:error] = I18n.t('projects.edit.invalid_transferred')
      redirect_to project_path(@current_project)
    end
  end

  def destroy
    authorize! :destroy, @current_project
    @current_project.destroy
    flash[:success] = t('projects.edit.deleted')
    redirect_to projects_path
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

  protected
  
    def load_projects
      @projects = current_user.projects.unarchived
    end

    def redirect_to_invite_people?
      Rails.env.cucumber? || Teambox.config.allow_outgoing_email?
    end

end
