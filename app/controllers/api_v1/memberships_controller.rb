class ApiV1::MembershipsController < ApiV1::APIController
  skip_before_filter :load_project
  before_filter :load_organization
  before_filter :load_membership, :except => [:index]
  
  def index
    api_respond @organization.memberships(:include => [:organization, :user]), :references => [:organization, :user]
  end

  def show
    api_respond @membership, :include => [:user]
  end
  
  def update
    authorize! :admin, @organization
    
    if @membership.update_attributes(params)
      handle_api_success(@membership)
    else
      handle_api_error(@membership)
    end
  end

  def destroy
    authorize! :admin, @organization
    
    if @organization.memberships.length > 1
      @membership.destroy
      handle_api_success(@membership)
    else
      api_error(t('common.not_allowed'), :unauthorized)
    end
  end

  protected
  
  def load_membership
    @membership = @organization.memberships.find_by_id(params[:id])
    api_status(:not_found) unless @membership
  end
  
end