class ApiV1::ProjectsController < ApiV1::APIController
  before_filter :can_modify?, :only => [:edit, :update, :transfer, :destroy]
  
  def index
    @projects = current_user.projects
    
    respond_to do |f|
      f.json  { render :as_json => @projects.to_xml }
    end
  end

  def show
  end
  
  def new
    @project = Project.new
  end
  
  def create
    @project = current_user.projects.new(params[:project])
    
    unless current_user.can_create_project?
      api_error(t('projects.new.not_allowed'), :unprocessable_entity)
      return
    end
    
    respond_to do |f|
      if @project.save
        handle_api_success(f, @project, true)
      else
        handle_api_error(f, @project)
      end
    end
  end
  
  def edit
  end
  
  def update
    respond_to do |f|
      if @current_project.update_attributes(params[:project])
        handle_api_success(f, @current_project)
      else
        handle_api_error(f, @current_project)
      end
    end
  end
  
  def transfer
    unless @current_project.owner?(current_user)
      api_error(t('common.not_allowed'), :unprocessable_entity)
      return
    end
    
    # Grab new owner
    user_id = params[:project][:user_id] rescue nil
    person = @current_project.people.find_by_user_id(user_id)
    saved = false
    
    # Transfer!
    unless person.nil?
      @current_project.user = person.user
      person.update_attribute(:role, Person::ROLES[:admin]) # owners need to be admin!
      saved = @current_project.save
    end
    
    if saved
      api_updated(@project, :edited)
    else
      api_error(@project.errors, :unprocessable_entity)
    end
  end

  def destroy
    @current_project.destroy
    respond_to do |f|
      handle_api_success(f,@current_project)
    end
  end

  protected
  
  def can_modify?
    if !( @current_project.owner?(current_user) or 
          ( @current_project.admin?(current_user) and 
            !(params[:controller] == 'transfer' or params[:sub_action] == 'ownership')))
      
      api_error(t('common.not_allowed'), :unprocessable_entity)
      return false
    end
    
    true
  end
  
end