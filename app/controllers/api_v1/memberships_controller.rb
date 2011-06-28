class ApiV1::MembershipsController < ApiV1::APIController
  skip_before_filter :load_project
  before_filter :load_organization
  before_filter :load_membership, :except => [:index]
  
  def index
    authorize! :show, @organization
    
    @memberships = @organization.memberships.except(:order).
                                             where(api_range('memberships')).
                                             limit(api_limit).
                                             order('memberships.id DESC').
                                             includes([:organization, :user])
    
    api_respond @memberships, :references => true
  end

  def show
    authorize! :show, @membership
    api_respond @membership, :references => true
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
    
    if @membership.destroy
      handle_api_success(@membership)
    else
      handle_api_error(@membership)
    end
  end

  protected
  
  def load_membership
    @membership = @organization.memberships.find_by_id(params[:id])
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Membership not found' unless @membership
  end
  
end