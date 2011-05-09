class TaskListTemplatesController < ApplicationController
  skip_before_filter :load_project
  before_filter :load_organization

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "You're not allowed to do that."
    redirect_to organization_memberships_path(@organization)
  end

  def index
    @task_list_templates = @organization.task_list_templates
  end

  def create
    task_list_template = @organization.task_list_templates.build(params[:task_list_template])
    if task_list_template.save
      render :json => task_list_template.to_json
    else
      head :error
    end
  end

  def update
    task_list_template = @organization.task_list_templates.find(params[:id])
    task_list_template.update_attributes params[:task_list_template]
    render :json => task_list_template.to_json
  end

  def destroy
    task_list_template = @organization.task_list_templates.find(params[:id])
    if task_list_template.destroy
      render :json => task_list_template.to_json
    else
      head :error
    end
  end

  def reorder
    template_ids = params[:task_list_templates].collect(&:to_i)
    template_ids.each_with_index do |id, i|
      template = @organization.task_list_templates.find(id)
      template.update_attribute :position, i
    end
    head :ok
  end

  protected

  def load_organization
    unless @organization = current_user.organizations.find_by_permalink(params[:organization_id])
      if organization = Organization.find_by_permalink(params[:organization_id])
        redirect_to external_view_organization_path(@organization)
      else
        flash[:error] = t('organizations.edit.invalid')
        redirect_to root_path
      end
    end
  end

end

