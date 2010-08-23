require 'spec_helper'

describe Conversation do

  it "creates with first comment" do
    conversation = Factory.build(:simple_conversation, :body => nil)
    conversation.comments_attributes = {"0" => { :body => "Just sayin' hi" }}
    
    lambda {
      conversation.save.should be_true
    }.should change(described_class, :count)
    
    conversation.name.should be_nil
    
    comment = conversation.comments.first
    comment.body.should == "Just sayin' hi"
    comment.user.should == conversation.user
    comment.project.should == conversation.project
  end
  
  it "fails with blank comment" do
    conversation = Factory.build(:simple_conversation, :body => nil)
    conversation.comments_attributes = {"0" => { :body => "" }}
    
    lambda {
      conversation.save.should be_false
      conversation.errors.on(:comments).should == "The conversation must start with a non-blank comment."
    }.should_not change(described_class, :count)
  end
  
  it "fails with blank name if not simple" do
    conversation = Factory.build(:conversation, :name => "", :simple => false)
    conversation.save.should be_false
    conversation.errors.on(:name).should == "Please give this conversation a title."
  end
  
  it "allows blank name if simple" do
    conversation = Factory.build(:conversation, :name => "", :simple => true)
    conversation.save.should be_true
    conversation.name.should be_nil
  end

end
