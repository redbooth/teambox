class PublicProjectsFlag < ActiveRecord::Migration
  def self.up
    add_column :projects, :public, :boolean
  end

  def self.down
    remove_column :projects, :public
  end
end
