module PeopleHelper

  def person_link(project,person)
    link_to "#{person.name}", user_path(person.user)
  end
  
  def list_people(people)
    render :partial => 'person_list', :collection => people, :as => :person
  end
  
  def display_actions(person)
    can_transfer = (@current_user == person.project.user)
    owner = (person.project.user == person.user)
    me = (@current_user == person.user)
    actions = []
    actions << t('.owner') if owner
    actions << leave_project_link(person) if me and not owner
    actions << delete_person_link(person) unless me or owner
    actions << t('.transfer') if can_transfer and not owner
    actions.join('<br/>')
  end
  
  def delete_person_link(person)
    link_to_remote t('.remove'), :url => project_person_path(@current_project,person.user.id), :method => :delete,
      :confirm => t('.confirm_delete')
  end

  def leave_project_link(person)
    link_to_remote t('.leave_project'), :url => project_person_path(@current_project,person.user.id), :method => :delete,
      :confirm => t('.confirm_delete')
  end
end