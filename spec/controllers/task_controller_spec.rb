require File.dirname(__FILE__) + '/../spec_helper'

describe TasksController do
  before do
    @user = Factory(:confirmed_user)
    @project = Factory(:project)
    @project.add_user @user
  end

  describe "#create" do
    it "should set the due date" do
      task_list = Factory(:task_list, :project => @project, :user => @user)
      login_as @user

      post  :create, :project_id => @project.permalink, :task_list_id => task_list.id,
            :task => { :name => 'This should work', :due_on => 'September 30, 2010'}
      # This will be changed when Mislav fixes the bug
      # that prevents due date if the locale is not english,
      # because we'll be sending a date that's not in human form

      task = task_list.tasks.last(:order => 'created_at desc')
      task.name.should == 'This should work'
      task.due_on.should == 'September 30, 2010'.to_date
    end
  end
end
