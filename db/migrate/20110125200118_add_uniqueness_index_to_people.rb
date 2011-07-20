class AddUniquenessIndexToPeople < ActiveRecord::Migration
  def self.up
    remove_index :people, [:user_id, :project_id]
    Person.connection.execute <<-EOF
      DELETE #{Person.table_name}
      FROM #{Person.table_name}
      LEFT OUTER JOIN (
         SELECT MIN(id) as id, user_id, project_id
         FROM #{Person.table_name}
         GROUP BY user_id, project_id) as KeepRows ON
         #{Person.table_name}.id = KeepRows.id
      WHERE
         KeepRows.id IS NULL
    EOF
    add_index :people, [:user_id, :project_id], :unique => true
  end

  def self.down
    remove_index :people, [:user_id, :project_id]
    add_index :people, [:user_id, :project_id]
  end
end
