class MembershipsController < ApplicationController

  skip_before_filter :load_project
  before_filter :load_organization
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "You're not allowed to do that. Only admins of an organization have that right."
    redirect_to organization_memberships_path(@organization)
  end

  def index
    @users_not_belonging_to_org = @organization.external_users
  end

  def change_role
    authorize! :admin, @organization
    membership = @organization.memberships.find_or_create_by_user_id(params[:id])
    membership.role = params[:role].to_i
    unless membership.save
      flash[:error] = "Couldn't do that."
    end
    redirect_to organization_memberships_path(@organization)
  end

  def add
    authorize! :admin, @organization
    unless @organization.add_member(params[:id], params[:role])
      flash[:error] = "Couldn't add user to the organization"
    end
    redirect_to organization_memberships_path(@organization)
  end

  def remove
    authorize! :admin, @organization  
    membership = @organization.memberships.find_by_user_id(params[:id])
    unless membership.try(:destroy)
      flash[:error] = "Couldn't find that membership"
    end
    redirect_to organization_memberships_path(@organization)
  end

  protected

    def load_organization
      unless @organization = current_user.organizations.find_by_permalink(params[:organization_id])
        flash[:error] = "Invalid organization"
        redirect_to root_path
      end
    end

end