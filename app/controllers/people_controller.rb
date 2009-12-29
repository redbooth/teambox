class PeopleController < ApplicationController
  before_filter :load_person, :only => [:update,:destroy]

  def index
    @people = @current_project.people
    @invitations = @current_project.invitations
    @contacts = @current_user.contacts_not_in_project(@current_project)
    
    invited_user_ids = @invitations.collect { |i| i.invited_user_id }
    @contacts.reject! { |c| invited_user_ids.include?(c.id) }
  end
  
  def create
    user = User.find_by_email(params[:search]) || User.find_by_login(params[:search])

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
    if @user == current_user
      @person.try(:destroy)

      flash[:success] = t('deleted.left_project', :name => @user.name)
      redirect_to root_path
    elsif @current_project.admin?(current_user)
      @person.try(:destroy)

      respond_to do |f|
        f.html do
          flash[:success] = t('deleted.person', :name => @user.name)
          redirect_to project_people_path(@current_project)
        end
        f.js
      end
    else
      flash[:error] = "You are not allowed to do that!"
      redirect_to project_people_path(@current_project)
    end
  end
  
  protected
    def load_person
      @person = @current_project.people.find(params[:id])
      @user = @person.user
    end
end