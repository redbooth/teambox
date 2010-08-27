class OrganizationsController < ApplicationController
  skip_before_filter :load_project
  before_filter :load_organization, :only => [:show, :edit, :update, :projects]
  before_filter :redirect_community, :only => [:index, :new, :create]

  def index
    @page_title = t('organizations.index.title')
    @organizations = current_user.organizations
  end

  def show
    @page_title = @organization
    redirect_to edit_organization_path(@organization)
  end

  def members
    @page_title = @organization
    @users_not_belonging_to_org = @organization.external_users
  end

  def projects
    @page_title = @organization
    @people = current_user.people
    @roles = {  Person::ROLES[:observer] =>    t('roles.observer'),
                Person::ROLES[:commenter] =>   t('roles.commenter'),
                Person::ROLES[:participant] => t('roles.participant'),
                Person::ROLES[:admin] =>       t('roles.admin') }
  end

  def new
    @organization = current_user.organizations.build
  end

  def create
    @organization = Organization.new(params[:organization])

    if @organization.save
      @organization.memberships.create!(:user_id => current_user.id, :role => Membership::ROLES[:admin])
      flash[:notice] = I18n.t('projects.new.created')
      redirect_to organization_path(@organization)
    else
      flash.now[:error] = I18n.t('projects.new.invalid_project')
      render :new
    end
    
  end
  
  def edit
    @page_title = @organization
  end

  def update
    @page_title = @organization
    if @organization.update_attributes(params[:organization])
      flash.now[:success] = t('organizations.edit.saved')
    end
    render :edit
  end

  def external_view
    @organization = Organization.find_by_permalink(params[:id])
  end

  protected

    def load_organization
      unless @organization = current_user.organizations.find_by_permalink(params[:id])
        if organization = Organization.find_by_permalink(params[:id])
          redirect_to external_view_organization_path(@organization)
        else
          flash[:error] = t('organizations.edit.invalid')
          redirect_to root_path
        end
      end
    end

    def redirect_community
      if Teambox.config.community
        flash[:error] = t('organizations.not_in_community')
        redirect_to root_path
      end
    end

end
