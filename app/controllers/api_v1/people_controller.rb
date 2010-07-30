class ApiV1::PeopleController < ApiV1::APIController
  before_filter :load_person, :except => [:index]
  before_filter :check_permissions, :only => [:update]
  
  def index
    @people = @current_project.people
    
    api_respond @people.to_json
  end

  def show
    api_respond @person.to_json
  end
  
  def update
    if !@current_project.owner?(@person.user) && @person.update_attributes(params[:person])
      handle_api_success(@person)
    else
      handle_api_error(@person)
    end
  end

  def destroy
    has_permission = !@current_project.owner?(@person.user) && ((current_user == @person.user) or 
                      @current_project.admin?(current_user))
    if has_permission
      @person.destroy
      handle_api_success(@person)
    else
      handle_api_error(@person, :status => :unauthorized)
    end
  end

  protected
  
  def load_person
    @person = @current_project.people.find params[:id]
    api_status(:not_found) unless @person
  end
  
  def check_permissions
    unless @current_project.admin?(current_user)
      api_error("You don't have permission to administer within \"#{@current_project.name}\" project", :unauthorized)
    end
  end
  
end