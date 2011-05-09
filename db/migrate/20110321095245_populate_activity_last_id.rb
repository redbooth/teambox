class PopulateActivityLastId < ActiveRecord::Migration
  def self.up
    Activity.where(:target_type => ['Task', 'Conversation']).where(:last_activity_id => nil).find_each do |activity|
      activity.update_attribute :last_activity_id,
        Activity.where(:target_type => 'Comment').where(:comment_target_type => activity.target_type).where(:comment_target_id => activity.target_id).order("id desc").first.id
    end
  end

  def self.down
  end
end
