require 'spec_helper'

describe Person do

  it "clears the assigned user on tasks when destroyed" do
    task = Factory :task
    person = task.project.people.first
    
    task.assign_to task.project.user
    task.assigned.should == person
    
    person.destroy
    
    task.reload.assigned_id.should be_nil
  end

  it "should recover the person when joining if the relation exists and is deleted" do
    project = Factory :project
    user = Factory :user
    project.add_user(user)

    person_id = project.people.find_by_user_id(user).id
    project.remove_user(user)

    project.reload.people.map(&:id).include?(person_id).should_not == true

    project.add_user(user)
    project.reload.people.map(&:id).include?(person_id).should == true
  end
end
