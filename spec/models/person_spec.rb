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
  
  it "should generate a delete activity with the correct date when destroyed" do
    project = Factory :project
    user = Factory :user
    
    now = Time.now
    Time.stub!(:now).and_return(now - 10.seconds)
    project.add_user(user)
    Time.stub!(:now).and_return(now + 10.seconds)
    
    person = project.people.find_by_user_id(user)
    person.destroy
    
    activity = project.activities.first
    activity.action.should == 'delete'
    activity.target.should == person
    activity.created_at.to_i.should == Time.now.to_i
  end

  it "should be created" do
    @user = Factory(:user)
    @project1 = Factory(:project)
    @project2 = Factory(:project)
    @user.projects(true).should be_empty
    @project1.add_user(@user)
    @project2.add_user(@user)
    @user.projects(true).should include(@project1, @project2)
  end
end
