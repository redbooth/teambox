require 'spec_helper'

describe ProjectsHelper do
  before do
    @user = Factory(:confirmed_user, :login => 'jordi', :first_name => 'Jordi', :last_name => 'Romero')
    @project = Factory(:project, :user => @user)
    login_as @user
  end

  describe "projects_people_data_json" do
    it "should render a hash of people in json" do
      project2 = Factory :project
      people_objects = 3.times.collect { Factory :person, :project => project2 }
      project2.add_user(@user)
      people = JSON.parse(projects_people_data_json)
      people.size.should == 2
      people[@project.id.to_s].should == [
        [@project.people.first.id.to_s, 'jordi', 'Jordi Romero', @user.id.to_s]
      ]
      people[project2.id.to_s].collect{ |p| p[1] }.should == ['jordi', project2.user.login] + people_objects.collect(&:user).collect(&:login)
    end
  end
end

