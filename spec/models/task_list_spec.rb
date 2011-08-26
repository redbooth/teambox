require File.dirname(__FILE__) + '/../spec_helper'

describe TaskList do

  it { should belong_to(:project) }
  it { should belong_to(:page) }
  it { should have_many(:comments) }
  it { should have_many(:tasks) }

  it { should validate_length_of(:name, :within => 1..255) }

  describe "factories" do
    it "should generate a valid task list" do
      task_list = Factory.create(:task_list)
      task_list.valid?.should be_true
    end
  end
  
  describe "references" do
    it "should reference the correct tasks" do
      task_list = Factory.create(:task_list)
      task_list.references[:task].should == nil
      resolved_task = Factory.create(:task, :name => "Go to RailsConf", :task_list => task_list, :status => Task::STATUSES[:resolved])
      unresolved_task = Factory.create(:task, :name => "Leave RailsConf", :task_list => task_list)
      task_list.reload.tasks.length.should == 2
      
      task_list.reference_task_objects = :task_ids
      task_list.task_ids.should == task_list.references[:task_list_task]
      task_list.reference_task_objects = :unarchived_task_ids
      task_list.unarchived_task_ids.should == task_list.references[:task_list_task]
      task_list.reference_task_objects = :archived_task_ids
      task_list.archived_task_ids.should == task_list.references[:task_list_task]
    end
  end

  describe "when deleted" do
    it "should delete its tasks" do
      task_list = Factory.create(:task_list, :name => "Be an excellent Rails dev.")
      nice_task = Factory.create(:task, :name => "Go to RailsConf", :task_list => task_list)
      task_list.destroy
      lambda { Task.find(nice_task.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
