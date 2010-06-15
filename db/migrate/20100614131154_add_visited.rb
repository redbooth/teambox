class AddVisited < ActiveRecord::Migration
  def self.up
    add_column :users, :visited_at, :datetime
    User.all.each do |user|
      user.update_attribute :visited_at, user.updated_at
    end
  end

  def self.down
    remove_column :users, :visited_at
  end
end
