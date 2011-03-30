class ApiV1::PeopleController < ApiV1::APIController
  before_filter :load_person, :except => [:index]
  
  def index
    authorize! :show, @current_project
    
    @people = @current_project.people.all({
      :conditions => api_range('people'),
      :limit => api_limit,
      :order => 'people.id DESC',
      :include => [:project, :user]})
    
    api_respond @people, :references => [:project, :user]
  end

  def show
    authorize! :show, @person
    api_respond @person, :include => [:user]
  end
  
  def update
    authorize! :update, @person
    if @person.update_attributes(params)
      handle_api_success(@person)
    else
      handle_api_error(@person)
    end
  end

  def destroy
    authorize! :destroy, @person
    @person.destroy
    handle_api_success(@person)
  end

  protected
  
  def load_person
    @person = @current_project.people.find params[:id]
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Person not found' unless @person
  end
  
end