class ApiV1::MembershipsController < ApiV1::APIController
  skip_before_filter :load_project
  before_filter :load_organization
  before_filter :load_membership, :except => [:index]
  before_filter :can_modify?, :only => [:update, :destroy]
  
  def index
    api_respond @organization.memberships.to_json
  end

  def show
    api_respond @membership.to_json(:include => [:projects, :members, :people])
  end
  
  def update
    if @membership.update_attributes(params[:membership])
      handle_api_success(@membership)
    else
      handle_api_error(@membership)
    end
  end

  def destroy
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
  
  def can_modify?
    if !@organization.is_admin?(current_user)
      api_error(t('common.not_allowed'), :unauthorized)
      false
    else
      true
    end
  end
  
end