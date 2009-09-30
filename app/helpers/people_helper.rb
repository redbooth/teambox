module PeopleHelper

  def person_link(project,person)
    link_to "#{person.name}", ''
  end
  
  def list_people(user)
    render :partial => 'users/user', :collection => users, :as => :user    
  end

  def person_status(person)
    'online' if person.updated_at > 5.minutes.ago
  end

end