class PeopleController < ApplicationController

  def index
  end
  
  def create
    user   = User.find_by_email params[:search]
    user ||= User.find_by_login params[:search]

    if user
      @current_project.add_person(user)
      flash[:success] = "#{user.name} has been invited to this project!"
      
      redirect_to project_people_path
    else
      flash[:error] = "User not found. Enter his username or email."
      redirect_to project_people_path
    end

  end
  
end