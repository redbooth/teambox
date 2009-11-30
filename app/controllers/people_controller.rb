class PeopleController < ApplicationController
  before_filter :load_person, :only => [:update,:destroy]
  def index
    @people = @current_project.people
  end
  
  def create
    user   = User.find_by_email params[:search]
    user ||= User.find_by_login params[:search]

    if user
      @current_project.add_user(user,current_user)
      flash[:success] = "#{user.name} has been invited to this project!"
      
      redirect_to project_people_path
    else
      flash[:error] = "User not found. Enter his username or email."
      redirect_to project_people_path
    end
  end
  
  def update
    @person.update_attributes(params[:person])
    respond_to {|f|f.js}
  end
  
  def destroy
    
    if @person.destroy
      respond_to do |f|
        f.html {
          flash[:success] = "#{@user.name} has been removed from this project!"
          redirect_to project_people_path }
        f.js
      end
    else
      respond_to do |f|
        f.html {
          flash[:error] = "Person not found."
          redirect_to project_people_path }
        f.js
      end
    end
  end
  
  protected
    def load_person
      @person = @current_project.people.find(params[:id])
    end
end