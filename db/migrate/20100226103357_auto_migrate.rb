class AutoMigrate < ActiveRecord::Migration
  def self.up
    AutoMigrations.run
  end

  def self.down
  end
end
