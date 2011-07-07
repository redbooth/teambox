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
      conversation.errors_on(:comments).should == ["The conversation cannot start with an empty comment."]
    }.should_not change(described_class, :count)
  end
  
  it "fails with blank name if not simple" do
    conversation = Factory.build(:conversation, :name => "", :simple => false)
    conversation.save.should be_false
    conversation.errors_on(:name).should == ["Please give this conversation a title."]
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
      :watcher_ids => [other_guy.id.to_s])
    
    conversation.watchers.should include(conversation.user)
    conversation.watchers.should include(person.user)
  end

  describe "is convertable to a task" do

    it "if is not simple" do
      conversation = Factory.create(:conversation, :simple => false)
      task = conversation.convert_to_task!
      task.should_not be_nil
      task.errors.should be_empty
      task.name.should == conversation.name
    end

    it "and when converted to a task should default to the Inbox task list if a task list is not supplied" do
      conversation = Factory.create(:conversation, :simple => false)
      conversation_comments = conversation.comments.map(&:id)
      conversation_activities = Activity.for_conversations.in_targets(conversation).map(&:id)
      task = conversation.convert_to_task!
      task.should_not be_nil
      task.task_list.should_not be_nil
      task.task_list.name.should == 'Inbox'
    end

    it "and when converted to a task should use supplied task_list" do
      task_list = Factory.create(:task_list)
      conversation = Factory.create(:conversation, :simple => false, 
                                                   :task_list_id => task_list.id)

      task = conversation.convert_to_task!
      task.should_not be_nil
      task.task_list.should_not be_nil
      task.task_list.name.should == task_list.name
    end

    it "and when converted to a task, the task status should default to :new" do
      conversation = Factory.create(:conversation, :simple => false)
      task = conversation.convert_to_task!
      task.should_not be_nil
      task.status_name.should == :new
    end

    it "and when converted to a task, due_on and assigned should be nil if not supplied" do
      conversation = Factory.create(:conversation, :simple => false)
      task = conversation.convert_to_task!
      task.should_not be_nil
      task.assigned.should be_nil
      task.due_on.should be_nil
    end

    it "and when converted to a task, the task should retain same created_at timestamp" do
      conversation = Factory.create(:conversation, :simple => false, :created_at => 2.hours.ago)

      task = conversation.convert_to_task!

      task.should_not be_nil
      task.created_at.to_s.should == conversation.created_at.to_s
    end

    it "and when converted to a task, the task's updated_at timestamp should be 'touched'" do
      conversation = Factory.create(:conversation, :simple => false, :created_at => 2.hours.ago, :updated_at => 1.hour.ago)

      task = conversation.convert_to_task!

      task.should_not be_nil
      task.updated_at.should be_within(1).of(Time.now)
    end

    it "and when converted to a task, the comments should be transferred to the task" do
      conversation = Factory.build(:conversation, :simple => false)
      conversation.comments_attributes = {"0" => { :body => "Just sayin' hi" }}
      conversation.save

      conversation_comments = conversation.comments.map(&:id)
      conversation.comments.should_not be_empty

      task = conversation.convert_to_task!

      task.should_not be_nil
      task.comments.all? {|comment| conversation_comments.include?(comment.id)}.should be_true
    end

    it "and when converted to a task, any new comments should also be transferred to the task" do
      conversation = Factory.create(:conversation, :simple => false)
      conversation.comments_attributes = {"0" => { :body => "Just sayin' hi" }}

      task = conversation.convert_to_task!

      task.should_not be_nil
      task.comments.any? {|comment| comment.body == "Just sayin' hi"}.should be_true
    end

    it "and when converted to a task, and any new comments have been transferred to the task, it should update the comment counter cache" do
      conversation = Factory.create(:conversation, :simple => false)
      conversation.comments_attributes = {"0" => { :body => "Just sayin' hi" }}

      task = conversation.convert_to_task!

      task.should_not be_nil
      task.comments_count.should == 2
    end

    it "and when converted to a task with due date, it should update the comment counter cache" do
      conversation = Factory.create(:conversation, :simple => false)
      conversation.comments_attributes = {"0" => { :body => "Just sayin' hi" }}
      conversation.updating_user = conversation.user # needed for the due_on change to be saved as a new comment
      conversation.due_on = 3.days.since

      task = conversation.convert_to_task!

      task.should_not be_nil
      task.comments(true).to_a.size.should == 3
      task.comments_count.should == 3 # original conversation + changing date + new comment
    end

    it "and when converted to a task, any new comment which fails validation should not be transferred to the task" do
      conversation = Factory.create(:conversation, :simple => false)
      conversation.comments_attributes = {"0" => { :body => "" }}

      task = conversation.convert_to_task!
      task.should_not be_nil
      task.comments.any? {|comment| comment.body == "Just sayin' hi"}.should be_false
    end

    it "and when converted to a task, the activities should be transferred to the task" do
      conversation = Factory.build(:conversation, :simple => false)
      conversation.comments_attributes = {"0" => { :body => "Just sayin' hi" }}
      conversation.save

      conversation_activities = Activity.for_conversations.in_targets(conversation).map(&:id)

      task = conversation.convert_to_task!
      task.should_not be_nil

      activities = Activity.for_tasks.in_targets(task)

      activities.should_not be_empty
      activities.size.should == conversation_activities.size

      activities.all? do |activity| 
        conversation_activities.include?(activity.id) &&
        (activity.target_type == 'Comment' ? (activity.comment_target_id == task.id && activity.comment_target_type == 'Task') : activity.target == task)
      end.should be_true
    end

    it "and when converted to a task, the task should have an assigned person if supplied" do
      other_task = Factory :task
      person = other_task.project.people.first

      conversation = Factory.create(:conversation, 
                                    :simple => false,
                                    :project => other_task.project,
                                    :assigned_id => person.id)

      task = conversation.convert_to_task!
      task.should_not be_nil
      task.assigned.should_not be_nil
      task.assigned.should == person
    end

    it "and when converted to a task, the task should have a due date if supplied" do
      due_on = 2.days.from_now
      conversation = Factory.create(:conversation, 
                                    :simple => false,
                                    :due_on => due_on)

      task = conversation.convert_to_task!
      task.should_not be_nil
      task.due_on.should_not be_nil
      task.due_on.should == due_on
    end

    it "but should not be convertable to a task if simple and doesn't supply name" do
      conversation = Factory.create(:conversation, :name => nil, :simple => true)
      conversation.should be_valid

      task = conversation.convert_to_task!
      task.should_not be_nil
      task.errors.should_not be_empty
      conversation.errors.should_not be_empty
      task.errors.to_a.should == conversation.errors.to_a
    end

    it "if simple and a name is supplied" do
      conversation = Factory.create(:conversation, :simple => true)
      conversation.should be_valid
      conversation.name = "My task name"

      task = conversation.convert_to_task!

      task.should_not be_nil
      task.name.should == "My task name"
      task.errors.should be_empty
      conversation.errors.should be_empty
    end

    it "and should be destroyed" do
      conversation = Factory.create(:conversation, :simple => false)
      conversation.should be_valid

      task = conversation.convert_to_task!
      lambda {Conversation.find(conversation.id)}.should raise_error(ActiveRecord::RecordNotFound)
    end
    
    it "all related comments and activities should be private" do
      conversation = Factory.create(:conversation, :is_private => true, :simple => false)
      conversation.comments_attributes = {"0" => { :body => "Just sayin' hi" }}
      conversation.save!
      task = conversation.convert_to_task!
      task.should_not be_nil
      task.is_private.should == true
      task.comments(true).any?{|c|c.is_private}.should == true
      Activity.where(:target_id => task.id, :target_type => 'Task').each{|a| a.is_private.should == true}
      Activity.where(:comment_target_id => task.id, :comment_target_type => 'Task').each{|a| a.is_private.should == true}
    end
  end
  
  describe "private conversations" do
    
    it "should mark all related activities as private when created as private" do
      conversation = Factory.create(:conversation, :is_private => true)
      activities_for_thread(conversation) { |activity| activity.is_private.should == true }
    end
    
    it "should update the private status of related activities and comments each time its updated" do
      conversation = Factory.create(:conversation, :is_private => true)
      comment = conversation.comments.create_by_user conversation.user, {:body => 'Test'}
      upload = comment.uploads.build({:asset => mock_uploader('semicolons.js', 'application/javascript', "alert('what?!')")})
      comment.uploads << upload
      comment.save!
      
      activities_for_thread(conversation) { |activity| activity.is_private.should == true }
      conversation.comments.each{|c| c.is_private.should == true; c.uploads.each{|upload| upload.is_private.should == true} }
      conversation.update_attribute(:is_private, false)
      activities_for_thread(conversation) { |activity| activity.is_private.should == false }
      conversation.comments.reload.each{|c| c.is_private.should == false; c.uploads.each{|upload| upload.is_private.should == false} }
      conversation.update_attribute(:is_private, true)
      activities_for_thread(conversation) { |activity| activity.is_private.should == true }
      conversation.comments.reload.each{|c| c.is_private.should == true; c.uploads.each{|upload| upload.is_private.should == true} }
    end
    
    it "should still dispatch notification emails when private" do
      watcher = Factory.create(:user)
      Emailer.should_receive(:send_with_language)
      
      conversation = Factory.create(:conversation, :is_private => true)
      conversation.project.add_user(watcher)
      conversation.add_watcher(watcher)
      conversation.comments.create_by_user conversation.user, {:body => 'Nononotify'}
      conversation.save
      
      Conversation.find(conversation.id).comments.length.should == 2
    end
    
    it "only comments created by the owner can update is_private" do
      watcher = Factory.create(:user)
      conversation = Factory.create(:conversation, :is_private => true)
      conversation.project.add_user(watcher)
      conversation.add_watcher(watcher)
      
      conversation.comments.create_by_user watcher, {:body => 'shouldnotwork', :is_private => false}
      conversation.save
      conversation.reload.is_private.should == true
      
      conversation.comments.create_by_user conversation.user, {:body => 'shouldwork', :is_private => false}
      conversation.save
      conversation.reload.is_private.should == false
      
      conversation.comments.create_by_user watcher, {:body => 'doesntwork', :is_private => true}
      conversation.save
      conversation.reload.is_private.should == false
      
      conversation.comments.create_by_user conversation.user, {:body => 'reallydoeswork', :is_private => true}
      conversation.save
      conversation.reload.is_private.should == true
    end
    
    it "only comments created by the owner can update private_ids" do
      watcher = Factory.create(:user)
      conversation = Factory.create(:conversation, :is_private => true)
      conversation.project.add_user(watcher)
      conversation.add_watcher(watcher)
      current_watchers = Conversation.find_by_id(conversation.id).watcher_ids.sort
      
      conversation.comments.create_by_user watcher, {:body => 'shouldnotwork', :is_private => true, :private_ids => [conversation.user_id]}
      conversation.save
      Conversation.find_by_id(conversation.id).watcher_ids.should == current_watchers.sort
      
      conversation.comments.create_by_user conversation.user, {:body => 'shouldwork', :is_private => true, :private_ids => [conversation.user_id]}
      conversation.save
      Conversation.find_by_id(conversation.id).watcher_ids.should == [conversation.user_id]
    end
    
    it "private_ids can only be changed when is_private is set" do
      watcher = Factory.create(:user)
      project = Factory.create(:project)
      conversation = Factory.create(:conversation, :is_private => true, :project => project, :user => project.user)
      conversation = Conversation.find_by_id(conversation.id)
      conversation.project.add_user(watcher)
      conversation.add_watcher(watcher)
      conversation = Conversation.find_by_id(conversation.id)
      current_watchers = conversation.watcher_ids.sort
      
      conversation.comments.create_by_user conversation.user, {:body => 'shouldnotwork', :private_ids => [conversation.user_id]}
      conversation.save
      Conversation.find_by_id(conversation.id).watcher_ids.sort.should == current_watchers.sort
      
      conversation.comments.create_by_user conversation.user, {:body => 'shouldreallynotwork', :is_private => true, :private_ids => [conversation.user_id]}
      conversation.save
      Conversation.find_by_id(conversation.id).watcher_ids.sort.should == [conversation.user_id]
    end
    
    it "is_private cannot be mass assigned" do
      project = Factory.create(:project)
      conversation = project.conversations.new_by_user(project.user, :name => 'Test', :is_private => true)
      conversation.is_private.should == false
      conversation.update_attributes(:is_private => false)
      conversation.is_private.should == false
    end
  end
end

