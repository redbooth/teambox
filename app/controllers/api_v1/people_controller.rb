class ApiV1::PeopleController < ApiV1::APIController
  before_filter :load_person, :except => [:index]
  
  def index
    @people = @current_project.people
    
    respond_to do |f|
      f.json  { render :as_json => @people.to_xml }
    end
  end

  def show
    respond_to do |f|
      f.json  { render :as_json => @person.to_xml }
    end
  end
  
  def update
    respond_to do |f|
      if @person.update_attributes(params[:person])
        handle_api_success(f, @person)
      else
        handle_api_error(f, @person)
      end
    end
  end

  def destroy
    @person.destroy
    respond_to do |f|
      handle_api_success(f,@person)
    end
  end

  protected

  def load_person
    @person = @current_project.people.find params[:id]
  end
  
end