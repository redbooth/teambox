class ProjectsController < ApplicationController
  around_filter :set_time_zone, :only => [:index, :show]
  before_filter :load_projects, :only => [:index]
  before_filter :set_page_title
  before_filter :disallow_for_community, :only => [:new, :create]
  before_filter :load_pending_projects, :only => [:index, :show, :new, :create]
  
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |f|
      flash[:error] = t('common.not_allowed')
      f.any(:html, :m) { redirect_to projects_path }
    end
  end
  
  def index
    @new_conversation = Conversation.new(:simple => true)
    @activities = Activity.for_projects(@projects).
      where(['is_private = ? OR (is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
      joins("LEFT JOIN watchers ON ((activities.comment_target_id = watchers.watchable_id AND watchers.watchable_type = activities.comment_target_type) OR (activities.target_id = watchers.watchable_id AND watchers.watchable_type = activities.target_type)) AND watchers.user_id = #{current_user.id}")
    
    @threads = @activities.threads.all(:include => [:project, :target])
    @last_activity = @threads.last

    respond_to do |f|
      f.html do
        # If I can create a project and I don't have any, show me the create a project screen
        if can?(:create_project, @current_user) and !current_user.projects.any?
          @project = Project.new
          @project.build_organization
          render 'projects/new'
        end
      end
      f.m     { redirect_to activities_path if request.path == '/' }
      f.rss   { render :layout  => false }
      f.ics   { render :text    => Project.to_ical(@projects, current_user, params[:filter] == 'mine' ? current_user : nil, request.host, request.port) }
      f.print { render :layout  => 'print' }
    end
  end

  def show
    @activities = Activity.for_projects(@current_project).
      where(['activities.is_private = ? OR (activities.is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
      joins("LEFT JOIN watchers ON  ((activities.comment_target_id = watchers.watchable_id AND watchers.watchable_type = activities.comment_target_type) OR (activities.target_id = watchers.watchable_id AND watchers.watchable_type = activities.target_type)) AND watchers.user_id = #{current_user.id}")
    
    @threads = @activities.threads.all(:include => [:project, :target])
    @last_activity = @threads.last
    @recent_conversations = @current_project.conversations.not_simple.recent(4).reject { |c| !c.is_visible?(current_user) }
    @new_conversation = @current_project.conversations.new(:simple => true)

    respond_to do |f|
      f.any(:html, :m)
      f.rss   { render :layout  => false }
      f.ics   { render :text    => @current_project.to_ical(current_user, params[:filter] == 'mine' ? current_user : nil) }
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
        redirect_path = project_invite_people_path(@project)

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
    # TODO: sort by organization name and then by project name
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

end
