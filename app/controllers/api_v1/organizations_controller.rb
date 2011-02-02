class ApiV1::OrganizationsController < ApiV1::APIController
  skip_before_filter :load_project
  before_filter :load_organization, :except => [:create, :index]
  
  def index
    @organizations = current_user.organizations(:order => 'id DESC')
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
    organization_id ||= params[:id]
    
    if organization_id
      @organization = Organization.find_by_id_or_permalink(organization_id)
      unless @organization and @organization.is_user?(current_user)
        api_error :not_found, :type => 'ObjectNotFound', :message => 'Organization not found'
      end
    end
  end
  
  def api_include
    [:projects, :members] & (params[:include]||{}).map(&:to_sym)
  end
  
end
