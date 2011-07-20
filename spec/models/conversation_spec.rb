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
      :watchers_ids => [other_guy.id.to_s])
    
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
      task.comments_count.should == task.comments.length
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
  end
end

