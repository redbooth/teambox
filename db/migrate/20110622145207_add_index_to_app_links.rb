class AddIndexToAppLinks < ActiveRecord::Migration
  def self.up
    add_index :app_links, [:provider, :app_user_id]
  end

  def self.down
    remove_index :app_links, :column => [:provider, :app_user_id]
  end
end
