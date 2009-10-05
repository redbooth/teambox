module PeopleHelper

  def person_link(project,person)
    link_to "#{person.name}", ''
  end
  
  def list_people(people)
    render :partial => 'person_list', :collection => people, :as => :person
  end

  def person_status(person)
    'online' if person.updated_at > 5.minutes.ago
  end
  
  def delete_person_link(person)
    link_to_remote trash_image, :url => project_person_path(@current_project,person.user.id), :method => :delete,
      :confirm => t('.confirm_delete')
  end
end