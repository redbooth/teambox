class AddIndexForPageId < ActiveRecord::Migration
  def self.up
    add_index :notes, [:page_id]
    add_index :dividers, [:page_id]
    add_index :uploads, [:page_id]
  end

  def self.down
    remove_index :notes, :column => [:page_id]
    remove_index :dividers, :column => [:page_id]
    remove_index :uploads, :column => [:page_id]
  end
end
