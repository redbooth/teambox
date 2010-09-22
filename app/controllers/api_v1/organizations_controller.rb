class ApiV1::OrganizationsController < ApiV1::APIController
  skip_before_filter :load_project
  before_filter :load_organization, :except => [:create, :index]
  before_filter :can_modify?, :only => [:edit, :update, :destroy]
  
  def index
    api_respond current_user.organizations.to_json
  end

  def show
    api_respond @organization.to_json(:include => [:projects, :members, :people])
  end
  
  def create
    @organization = current_user.organizations.new(params[:organization])
    
    if !Teambox.config.community and @organization.save
      handle_api_success(@organization, :is_new => true)
    else
      handle_api_error(@organization)
    end
  end
  
  def update
    if @organization.update_attributes(params[:organization])
      handle_api_success(@organization)
    else
      handle_api_error(@organization)
    end
  end

  def destroy
    @organization.destroy
    handle_api_success(@organization)
  end

  protected
  
  def load_organization
    @organization = current_user.organizations.find_by_permalink(params[:id])
    api_status(:not_found) unless @organization
  end
  
  def can_modify?
    if !@organization.is_admin?(current_user)
      api_error(t('common.not_allowed'), :unauthorized)
      false
    else
      true
    end
  end
  
end