class AddIndexOnUsersEmail < ActiveRecord::Migration
  def self.up
    add_index :users, [:email, :deleted, :updated_at]
  end

  def self.down
    remove_index :users, :column => [:email, :deleted, :updated_at]
  end
end
