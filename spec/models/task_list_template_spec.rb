require File.dirname(__FILE__) + '/../spec_helper'

describe TaskListTemplate do

  it { should belong_to(:organization) }
  it { should validate_length_of(:name, :within => 1..255) }
  it { should validate_presence_of(:name) }

  describe "factories" do
    it "should generate a valid task list template" do
      template = Factory :task_list_template
      template.reload.should be_valid
      template.name.should == 'I will come up with a better name later'
      template.tasks.count.should == 3
      template.organization.should_not be_nil
    end

    it "should need an organization" do
      template = Factory.build(:task_list_template, :organization => nil)
      template.should_not be_valid
    end
  end

  it "should return an empty array if empty" do
    template = Factory(:task_list_template, :tasks => nil)
    template.tasks.should == []
  end

  it "should return an array of titles" do
    template = Factory(:task_list_template)
    template.tasks.class.should == Array
    template.tasks.each { |t| t.class.should == Array and t.size.should == 1 }
  end

  it "should contain task comments if provided" do
    template = Factory(:complete_task_list_template)
    template.tasks.class.should == Array
    template.tasks.each { |t| t.class.should == Array and t.size.should == 2 }
  end

  describe "creating task lists" do
    before do
      @user = Factory :user
      @project = Factory :project, :user => @user
    end

    it "should create a task list from a template without comments" do
      template = Factory :task_list_template, :organization => @project.organization
      list = template.create_task_list(@project, @user)
      list.tasks.collect { |t| [t.name] }.should == template.tasks
    end

    it "should create a task list with comments from a complete template" do
      template = Factory :complete_task_list_template, :organization => @project.organization
      list = template.create_task_list(@project, @user).reload
      list.tasks.collect { |t| [t.name, t.comments.first.try(:body)] }.should == template.tasks
    end

    it "should set the correct user" do
      template = Factory :complete_task_list_template, :organization => @project.organization
      list = template.create_task_list(@project, @user).reload
      list.user.should == @user
      list.tasks.each { |t| t.user.should == @user }
      list.tasks.each { |t| t.comments.each { |c| c.user.should == @user } }
    end

    it "should set the correct project" do
      template = Factory :complete_task_list_template, :organization => @project.organization
      list = template.create_task_list(@project, @user).reload
      list.project.should == @project
    end
  end
end

