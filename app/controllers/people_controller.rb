class PeopleController < ApplicationController
  before_filter :load_person, :only => [:update, :destroy]
  before_filter :set_page_title
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = t('common.not_allowed')
    redirect_to project_people_path(@current_project)
  end
  
  def index
    @people = @current_project.people.in_alphabetical_order.all
    @invitations = @current_project.invitations
    
    respond_to do |f|
      f.any(:html, :m)
      f.xml   { render :xml     => @people.to_xml(:root => 'people') }
      f.json  { render :as_json => @people.to_xml(:root => 'people') }
      f.yaml  { render :as_yaml => @people.to_xml(:root => 'people') }
    end
  end

  def update
    authorize! :update, @person
    @person.update_attributes params[:person]
    
    respond_to do |wants|
      wants.html {
        if request.xhr?
          render :partial => 'people/person', :locals => {:project => @current_project, :person => @person }
        else
          flash[:success] = t('people.update.success', :name => @person.user.name)
          redirect_to project_people_url(@current_project)
        end
      }
    end
  end

  def destroy
    authorize! :destroy, @person
    @person.destroy
      
    respond_to do |wants|
      wants.html {
        if request.xhr?
          head :ok
        elsif @user == current_user
          flash[:success] = t('deleted.left_project', :name => @user.name)
          redirect_to root_path
        else
          flash[:success] = t('deleted.person', :name => @user.name)
          redirect_to project_people_path(@current_project)
        end
      }
    end
  end
  
  def contacts
    @project = Project.find params[:id]
    
    if current_user.in_project(@project)
      users = @project.users
      
      invited_ids = @current_project.invitations.find(:all, :select => 'invited_user_id').map(&:invited_user_id).compact
      users = users.where(['users.id NOT IN (?)', invited_ids]) if invited_ids.any?
      
      @contacts = users.all
      @contacts -= @current_project.users
    end
    
    respond_to do |wants|
      wants.html { render :layout => false if request.xhr? }
    end
  end
  
  protected

  def load_person
    @person = @current_project.people.find params[:id]
    @user = @person.user
  end
end
