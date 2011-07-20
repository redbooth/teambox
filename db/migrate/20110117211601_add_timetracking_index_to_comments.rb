class AddTimetrackingIndexToComments < ActiveRecord::Migration
  def self.up
    add_index :comments, [:project_id]
    add_index :comments, [:created_at]
    add_index :comments, [:hours]
  end

  def self.down
    remove_index :comments, :column => [:project_id]
    remove_index :comments, :column => [:created_at]
    remove_index :comments, :column => [:hours]
  end
end
