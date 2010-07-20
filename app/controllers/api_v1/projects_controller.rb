class ApiV1::ProjectsController < ApiV1::APIController
  before_filter :can_modify?, :only => [:edit, :update, :transfer, :destroy]
  
  def index
    @projects = current_user.projects
    
    respond_to do |f|
      f.json  { render :as_json => @projects.to_xml }
    end
  end

  def show
    respond_to do |f|
      f.json  { render :as_json => @current_project.to_xml }
    end
  end
  
  def create
    @project = current_user.projects.new(params[:project])
    
    unless current_user.can_create_project?
      api_error(t('projects.new.not_allowed'), :unprocessable_entity)
      return
    end
    
    respond_to do |f|
      if @project.save
        handle_api_success(f, @project, :is_new => true)
      else
        handle_api_error(f, @project)
      end
    end
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
      saved = @current_project.transfer_to(person)
    end
    
    respond_to do |f|
      if saved
        handle_api_success(@project)
      else
        handle_api_success(@project)
      end
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
            params[:controller] != 'transfer'))
      
      api_error(t('common.not_allowed'), :unprocessable_entity)
      return false
    end
    
    true
  end
  
end