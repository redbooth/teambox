require 'spec_helper'

describe Activity do
  describe "target when deleting objects" do
    it "should still be valid when deleting core project objects" do
      
      project = Factory.create(:project)
      Factory.create(:comment, :project => project)
      Factory.create(:conversation, :project => project)
      Factory.create(:task_list, :project => project)
      Factory.create(:upload, :project => project)
      page = Factory.create(:page, :project => project)
      
      note = page.build_note({:name => 'Office Ettiquete'}).tap do |n|
        n.updated_by = project.user
        n.save
      end
      divider = page.build_note({:name => 'Office Ettiquete'}).tap do |n|
        n.updated_by = project.user
        n.save
      end
      
      Activity.count.should_not == 0
      Activity.all.any? { |a| a.target.nil? }.should == false
      
      Person.destroy_all
      Comment.destroy_all
      Conversation.destroy_all
      TaskList.destroy_all
      Page.destroy_all
      
      Activity.all.any? { |a| a.target.nil? }.should == false
    end
  end
end
