class AddUniquenessIndexToPeople < ActiveRecord::Migration
  def self.up
    remove_index :people, [:user_id, :project_id], :name => "index_people_on_user_id_and_project_id"
    add_index :people, [:user_id, :project_id], :name => "index_people_on_user_id_and_project_id", :unique => true
  end

  def self.down
    remove_index :people, [:user_id, :project_id], :name => "index_people_on_user_id_and_project_id"
    add_index :people, [:user_id, :project_id], :name => "index_people_on_user_id_and_project_id"
  end
end
