class AddSimpleToConversation < ActiveRecord::Migration
  def self.up
    add_column :conversations, :simple, :boolean, :default => false
  end

  def self.down
    remove_column :conversations, :simple
  end
end
