module PeopleHelper
  
  def options_from_person_roles
    Person::ROLES.map { |role, value| [t("people.fields.#{role}"), value] }.sort_by(&:last)
  end
  
  def options_from_other_projects(projects)
    "<option value=''>#{t('people.column.select_project')}</option>" +
      options_from_collection_for_select(projects, :id, :name)
  end

end
