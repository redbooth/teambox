class AddIndexOnNotes < ActiveRecord::Migration
  def self.up
    add_index :notes, :project_id
  end

  def self.down
    remove_index :notes, :project_id
  end
end
