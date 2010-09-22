module OrganizationsHelper

  def options_for_organizations(organizations)
    organizations.sort_by(&:name).collect { |o| [o.name, o.id ]}
  end

  def organization_navigation(organization)
    render_tabnav :organizations_nav do 
      add_tab do |t|
        t.named t('.general_settings')
        t.links_to organization_path(@organization)
        t.highlights_on :controller => :organizations, :action => :show
        t.highlights_on :controller => :organizations, :action => :edit
        t.highlights_on :controller => :organizations, :action => :update
      end
      add_tab do |t|
        t.named t('.admin_users')
        t.links_to organization_memberships_path(@organization)
        t.highlights_on :controller => :memberships
      end
      add_tab do |t|
        t.named t('.admin_projects')
        t.links_to projects_organization_path(@organization)
        t.highlights_on :controller => :organizations, :action => :projects
      end
      add_tab do |t|
        t.named t('.delete')
        t.links_to delete_organization_path(@organization)
        t.highlights_on :controller => :organizations, :action => :delete
      end if organization.is_admin? current_user
    end
  end

  def public_url_for_organization(organization)
    site_url(@organization)
  end

end