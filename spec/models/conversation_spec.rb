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
      conversation.errors.on(:comments).should == "The conversation cannot start with an empty comment."
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

  it "destroy itself when the last comment is destroy if simple" do
    conversation = Factory.build(:conversation, :simple => true)
    conversation.save
    @comment = conversation.comments.first.destroy
    Conversation.find_by_id(@comment.target.id).should be_nil
  end
  
  it "change to normal conversation if title is added to simple conversation" do
    conversation = Factory.build(:simple_conversation, :body => nil)
    conversation.comments_attributes = {"0" => { :body => "Just sayin' hi" }}
    conversation.save

    conversation.simple.should be_true
    conversation.name = "Change to normal conversation"
    conversation.save.should be_true
    conversation.simple.should be_false
  end

  it "allows watchers id on create" do
    project = Factory.create(:project)
    other_guy = Factory.create(:confirmed_user)
    person = Factory.create(:person, :project => project, :user => other_guy)
    
    conversation = Factory.create(:conversation, :project => project, :user => project.user,
      :watchers_ids => [other_guy.id.to_s])
    
    conversation.watchers.should include(conversation.user)
    conversation.watchers.should include(person.user)
  end

end
