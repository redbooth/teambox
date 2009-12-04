require File.dirname(__FILE__) + '/../spec_helper'

describe TaskList do
  
  it { should belong_to(:project) }
  it { should belong_to(:page) }
  it { should have_many(:comments) }
  it { should have_many(:tasks) }

  it { should validate_length_of :name, :within => 1..255 }

  describe "factories" do
    it "should generate a valid task list" do
      task_list = Factory.create(:task_list)
      task_list.valid?.should be_true
    end
  end

end
