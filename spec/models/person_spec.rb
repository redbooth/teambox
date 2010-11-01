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

end
