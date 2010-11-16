class AddSplashScreen < ActiveRecord::Migration
  def self.up
    add_column :users, :splash_screen, :boolean, :default => false
  end

  def self.down
    remove_column :users, :splash_screen
  end
end
