module OrganizationsHelper

  def options_for_organizations(organizations)
    organizations.sort_by(&:name).collect { |o| [o.name, o.id ]}
  end

  def public_url_for_organization(organization)
    site_url(@organization)
  end

end
