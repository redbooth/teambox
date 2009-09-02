module PeopleHelper

  def list_people(people)
    render :partial => 'people/person', :collection => people
  end

end