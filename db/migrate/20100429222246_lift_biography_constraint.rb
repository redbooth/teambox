class LiftBiographyConstraint < ActiveRecord::Migration
  def self.up
    change_column :users, :biography, :text, :null => true
  end

  def self.down
    change_column :users, :biography, :text, :null => false
  end
end
