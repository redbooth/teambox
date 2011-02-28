class Reinforcewatcheruniqueness < ActiveRecord::Migration
  def self.up
    remove_index :watchers, {:name => 'uniqueness_index'}
    Watcher.connection.execute <<-EOF
      DELETE #{Watcher.table_name}
      FROM #{Watcher.table_name}
      LEFT OUTER JOIN (
         SELECT MIN(id) as id, user_id, watchable_id, watchable_type
         FROM #{Watcher.table_name}
         GROUP BY user_id, watchable_id, watchable_type) as KeepRows ON
         #{Watcher.table_name}.id = KeepRows.id
      WHERE
         KeepRows.id IS NULL
    EOF
    add_index :watchers, [:user_id, :watchable_id, :watchable_type], :name => 'watchers_uniqueness_index', :unique => true
  end

  def self.down
    remove_index :watchers, {:name => 'watchers_uniqueness_index'}
    add_index :watchers, [:user_id, :watchable_id, :watchable_type], :name => 'uniqueness_index', :unique => true
  end
end
