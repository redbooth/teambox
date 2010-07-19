class AddVisited < ActiveRecord::Migration
  def self.up
    add_column :users, :visited_at, :datetime
  end

  def self.down
    remove_column :users, :visited_at
  end
end
