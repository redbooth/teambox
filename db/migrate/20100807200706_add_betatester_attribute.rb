class AddBetatesterAttribute < ActiveRecord::Migration
  def self.up
    add_column :users, :betatester, :boolean, :default => false
  end

  def self.down
    remove_column :users, :betatester
  end
end
