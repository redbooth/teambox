require 'spec_helper'

describe Watcher do

  describe "in projects" do
    before do
      @user = Factory.create(:confirmed_user)
      @project = Factory.create(:project)
    end

    it "should destroy the watcher after project deletion" do
      Watcher.create(:user => @user, :project => @project)

      lambda {
        @project.destroy
      }.should change(Watcher, :count).by(-1)
    end
  end

  describe "in conversations" do
    before do
      @user1 = Factory.create(:confirmed_user)
      @user2 = Factory.create(:confirmed_user)
      @project = Factory.create(:project)
      @person1 = @project.add_user(@user1)
      @person2 = @project.add_user(@user2)
    end

    it "should add watcher if user has set watch_new_conversation" do
      @person1.update_attribute(:watch_new_conversation, true)
      @person1.watch_new_conversation.should be_true
      conversation = true

      lambda {
        conversation = Factory.create(:conversation, :project => @project, :user => @project.user)
      }.should change(Watcher, :count).by(2)

      conversation.watchers.should include(@user1)
    end

    it "should not add watcher if its private and user has set watch_new_conversation" do
      @person1.update_attribute(:watch_new_conversation, true)
      @person1.watch_new_conversation.should be_true
      conversation = true

      lambda {
        conversation = Factory.create(:conversation, :project => @project, :user => @project.user, :comments_attributes => [{ :body => "Hello there motherfucker", :is_private => true }])
      }.should change(Watcher, :count).by(1)
      conversation.watchers.should include(@project.user)
      conversation.watchers.should_not include(@user1)
    end

    it "should add conversation's user as a watcher" do
      conversation = true

      lambda {
        conversation = Factory.create(:conversation, :project => @project, :user => @project.user)
      }.should change(Watcher, :count).by(1)

      conversation.watchers.should include(conversation.user)
    end

    it "should save conversation's project to watcher" do
      conversation = Factory.create(:conversation, :project => @project, :user => @project.user)

      conversation.watcher_tags.first.project.should == @project
    end

    it "should add conversation's user if changed" do
      conversation = Factory.create(:conversation, :project => @project, :user => @project.user)
      conversation.watchers.should include(@project.user)

      conversation.user = @user1

      lambda {
        conversation.save.should be_true
      }.should change(Watcher, :count).by(1)

      conversation.watchers(true).should include(@user1)
    end

    it "should not add conversation's user if already watching" do
      @person1.update_attribute(:watch_new_conversation, true)
      @person1.watch_new_conversation.should be_true

      conversation = Factory.create(:conversation, :project => @project, :user => @project.user)
      conversation.watchers.should include(@user1)

      conversation.user = @user1

      lambda {
        conversation.save
      }.should_not change(Watcher, :count)

    end

    it "should add watcher if specified via watcher_ids" do
      conversation = Factory.build(:conversation, :project => @project, :user => @project.user)
      conversation.watcher_ids = [@user1.id.to_s]

      lambda {
        conversation.save
      }.should change(Watcher, :count).by(2)

      conversation.watchers.should include(@user1)
    end

    it "should never duplicate watchers" do 
      conversation = nil
      @person1.update_attribute(:watch_new_conversation, true)
      @person1.watch_new_conversation.should be_true

      lambda {
        conversation = Factory.create(:conversation, 
                                      :project => @project, 
                                      :user => @project.user)
      }.should change(Watcher, :count).by(2)

      lambda {
        conversation.watchers << @user2
        conversation.save.should be_true
      }.should change(Watcher, :count).by(1)

      conversation.watchers(true).size.should == 3
    end

    it "should allow assigning watchers id via mass assignment" do
      conversation = nil

      lambda {
        conversation = Factory.create(:conversation, 
                                      :project => @project, 
                                      :user => @project.user,
                                      :watcher_ids => [@project.user.id.to_s, @user1.id.to_s])
      }.should change(Watcher, :count).by(2)

      conversation.watchers(true).should include(@project.user)
      conversation.watchers.should include(@user1)
    end

    # aka it should not raise a Duplicate entry/unique error when trying to add conversation owner
    # as a watcher when autosaving watchers association (Already added via update_watchers).
    it "should not duplicate conversation's user if they have set watch_new_conversation" do
      @person1.update_attribute(:watch_new_conversation, true)
      @person2.update_attribute(:watch_new_conversation, true)

      @person1.watch_new_conversation.should be_true
      @person2.watch_new_conversation.should be_true

      conversation = true

      lambda {
        conversation = Factory.create(:conversation, :project => @project, :user => @user1)
      }.should change(Watcher, :count).by(2)

      conversation.watchers.should include(@user1)
      conversation.watchers.should include(@user2)
    end

  end

  describe "in tasks" do
    before do
      @user1 = Factory.create(:confirmed_user)
      @user2 = Factory.create(:confirmed_user)
      @project = Factory.create(:project)
      @person1 = @project.add_user(@user1)
      @person2 = @project.add_user(@user2)
    end

    it "should add watcher if user has set watch_new_task" do
      @person1.update_attribute(:watch_new_task, true)
      @person1.watch_new_task.should be_true
      task = true

      lambda {
        task = Factory.create(:task, :project => @project, :user => @project.user)
      }.should change(Watcher, :count).by(2)

      task.watchers.should include(@user1)
    end

    it "should not add watcher if its private and user has set watch_new_task" do
      @person1.update_attribute(:watch_new_task, true)
      @person1.watch_new_task.should be_true
      task = true

      lambda {
        task = Factory.create(:task, :project => @project, :user => @project.user, :is_private => true)
      }.should change(Watcher, :count).by(1)

      task.watchers.should_not include(@user1)
    end

    it "should add task's user as a watcher" do
      task = true

      lambda {
        task = Factory.create(:task, :project => @project, :user => @project.user)
      }.should change(Watcher, :count).by(1)

      task.watchers(true).should include(task.user)
    end

    it "should save task's project to watcher" do
      task = Factory.create(:task, :project => @project, :user => @project.user)

      task.watcher_tags.first.project.should == @project
    end

    it "should add task's user if changed" do
      task = Factory.create(:task, :project => @project, :user => @project.user)
      task.watchers(true).should include(@project.user)

      task.user = @user1

      lambda {
        task.save.should be_true
      }.should change(Watcher, :count).by(1)

      task.watchers(true).should include(@user1)
    end

    it "should not add task's user if already watching" do
      @person1.update_attribute(:watch_new_task, true)
      @person1.watch_new_task.should be_true

      task = Factory.create(:task, :project => @project, :user => @project.user)
      task.watchers.should include(@user1)

      task.user = @user1

      lambda {
        task.save
      }.should_not change(Watcher, :count)

    end

    it "should add watcher if specified via watcher_ids" do
      task = Factory.build(:task, :project => @project, :user => @project.user)
      task.watcher_ids = [@user1.id.to_s]

      lambda {
        task.save
      }.should change(Watcher, :count).by(2)

      task.watchers.should include(@user1)
    end

    it "should never duplicate watchers" do 
      task = nil
      @person1.update_attribute(:watch_new_task, true)
      @person1.watch_new_task.should be_true

      lambda {
        task = Factory.create(:task, 
                                      :project => @project, 
                                      :user => @project.user)
      }.should change(Watcher, :count).by(2)

      lambda {
        task.watchers << @user2
        task.save.should be_true
      }.should change(Watcher, :count).by(1)

      task.watchers(true).size.should == 3
    end

    it "should allow assigning watchers id via mass assignment" do
      task = nil

      lambda {
        task = Factory.create(:task, 
                                      :project => @project, 
                                      :user => @project.user,
                                      :watcher_ids => [@project.user.id.to_s, @user1.id.to_s])
      }.should change(Watcher, :count).by(2)

      task.watchers(true).should include(@project.user)
      task.watchers.should include(@user1)
    end

    # aka it should not raise a Duplicate entry/unique error when trying to add task owner
    # as a watcher when autosaving watchers association (Already added via update_watchers).
    it "should not duplicate task's user if they have set watch_new_task" do
      @person1.update_attribute(:watch_new_task, true)
      @person2.update_attribute(:watch_new_task, true)

      @person1.watch_new_task.should be_true
      @person2.watch_new_task.should be_true

      task = true

      lambda {
        task = Factory.create(:task, :project => @project, :user => @user1)
      }.should change(Watcher, :count).by(2)

      task.watchers.should include(@user1)
      task.watchers.should include(@user2)
    end

  end

end

