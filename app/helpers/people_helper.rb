module PeopleHelper
  
  def options_from_person_roles
    Person::ROLES.map { |role, value| [t("people.fields.#{role}"), value] }.sort_by(&:last)
  end

  def options_from_organization_roles
    Membership::ROLES.map { |role, value| [t("memberships.roles.#{role}"), value] }.sort_by(&:last)
  end
  
  def options_from_other_projects(projects)
    ("<option value=''>#{t('people.column.select_project')}</option>" +
      options_from_collection_for_select(projects, :id, :name)).html_safe
  end

  def options_for_projects_by_organization(commentable_projects)
    commentable_projects.group_by(&:organization).collect do |org,projects|
      "<optgroup label='#{h(org)}'>" +
        options_from_collection_for_select(projects, :id, :name) +
      "</optgroup>"
    end.join.html_safe
  end

end
