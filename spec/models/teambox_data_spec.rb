require 'spec_helper'
describe TeamboxData do
  before do
    @project = Factory(:project)
    @task_list = Factory(:task_list, :project => @project)
    @conversation = Factory(:conversation, :project => @project)
    @task = Factory(:task, :task_list_id => @task_list.id, :project => @project)
  end
  
  describe "unserialize" do
    it "should unserialize data" do
      data = dump_test_data
      old_project_count = Project.count
      
      Project.destroy_all
      Organization.destroy_all
      
      Project.count.should == 0
      Organization.count.should == 0
      
      TeamboxData.new.tap{|d| d.data = data }.unserialize({}, {:create_organizations => true})
      
      Project.count.should == old_project_count
    end
    
    it "should map existing data where specified" do
    end
    
    it "should create users when specified" do
      data = dump_test_data
      old_user_count = User.count
      old_project_count = Project.count
      
      User.destroy_all
      Project.destroy_all
      Organization.destroy_all
      
      User.count.should == 0
      Project.count.should == 0
      Organization.count.should == 0
      
      TeamboxData.new.tap{|d| d.data = data }.unserialize({}, {:create_users => true, :create_organizations => true})
      
      User.count.should == old_user_count
      Project.count.should == old_project_count
    end
  end
  
  describe "serialize" do
    it "should serialize data" do
      encoded_data = ActiveSupport::JSON.encode TeamboxData.new.serialize(Organization.all, Project.all, User.all)
      account_dump = ActiveSupport::JSON.decode(encoded_data)['account']
      account_dump['projects'].length.should == 1
      project_dump = account_dump['projects'][0]
      project_dump['task_lists'].length.should == 1
      project_dump['task_lists'][0]['tasks'].length.should == 1
      project_dump['conversations'].length.should == 1
      
      project_dump['id'].should == @project.id
      project_dump['task_lists'][0]['id'].should == @task_list.id
      project_dump['task_lists'][0]['tasks'][0]['id'].should == @task.id
      project_dump['conversations'][0]['id'].should == @conversation.id
      project_dump['conversations'][0]['comments'][0]['id'].should == @conversation.comments.first.id
    end
  end
  
  describe "import_from_file" do
    it "should import data from a file" do
    end
  end
  
  describe "export_to_file" do
    it "should export data to a file" do
    end
  end
end
