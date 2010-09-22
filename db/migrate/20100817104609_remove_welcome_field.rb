class RemoveWelcomeField < ActiveRecord::Migration
  def self.up
    remove_column :users, :welcome
  end

  def self.down
    add_column :users, :welcome, :boolean
  end
end
