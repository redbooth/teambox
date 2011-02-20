class AddIndexesForPeopleAndActivities < ActiveRecord::Migration
  def self.up
    add_index :people, [:project_id]
    add_index :people, [:user_id]
    add_index :people, [:deleted_at]
    add_index :activities, [:target_type]
    add_index :activities, [:target_id]
  end

  def self.down
    remove_index :activities, :column => [:target_id]
    remove_index :activities, :column => [:target_type]
    remove_index :people, :column => [:deleted_at]
    remove_index :people, :column => [:user_id]
    remove_index :people, :column => [:project_id]
  end
end
