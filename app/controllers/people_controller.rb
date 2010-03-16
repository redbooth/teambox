class PeopleController < ApplicationController
  before_filter :load_person, :only => [:update,:destroy]
  before_filter :set_page_title
  
  def index
    @people = @current_project.people
    @invitations = @current_project.invitations
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
  
  def contacts
    begin
      @other_project = Project.find_by_id(params[:pid])
    rescue
      @other_project = nil
    end
    
    if current_user.in_project(@other_project)
      # Strip invited people
      if @other_project
        invited_ids = @current_project.invitations.find(:all, :select => 'invited_user_id').map(&:invited_user_id).compact
        conds = invited_ids.empty? ? [] : ['users.id NOT IN (?)', invited_ids]
        @contacts = @other_project.users.find(:all, :conditions => conds) - @current_project.users
      end
    end
    
    @contacts ||= []
    
    respond_to do |f|
      f.js {}
    end
  end
  
  protected
    def load_person
      @person = @current_project.people.find(params[:id])
      @user = @person.user
    end
end