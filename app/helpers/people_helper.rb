module PeopleHelper
  
  def people_role_options
    Person::ROLES.map {|k,v| [ t("people.fields.#{k}"), v ] }.sort{|a,b| a[1] <=> b[1]}
  end
  
  def person_project_select_options(project)
    {:id => 'people_project_select', :people_url => project_contacts_path(project)}
  end

end