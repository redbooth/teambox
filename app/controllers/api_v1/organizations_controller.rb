class ApiV1::OrganizationsController < ApiV1::APIController
  skip_before_filter :load_project
  before_filter :load_organization, :except => [:create, :index]
  
  def index
    @organizations = current_user.organizations
    api_respond current_user.organizations, :references => []
  end

  def show
    api_respond @organization, :include => api_include
  end
  
  def create
    @organization = current_user.organizations.new(params)
    
    if !Teambox.config.community and @organization.save
      membership = @organization.memberships.build(:role => Membership::ROLES[:admin])
      membership.user_id = current_user.id
      membership.save!
      handle_api_success(@organization, :is_new => true)
    else
      handle_api_error(@organization)
    end
  end
  
  def update
    authorize! :admin, @organization
    if @organization.update_attributes(params)
      handle_api_success(@organization)
    else
      handle_api_error(@organization)
    end
  end

  def destroy
    authorize! :admin, @organization
    @organization.destroy
    handle_api_success(@organization)
  end

  protected
  
  def load_organization
    @organization = if params[:id].match(API_NONNUMERIC)
      current_user.organizations.find_by_permalink(params[:id])
    else
      current_user.organizations.find_by_id(params[:id])
    end
    api_status(:not_found) unless @organization
  end
  
  def api_include
    [:projects, :members] & (params[:include]||{}).map(&:to_sym)
  end
  
end