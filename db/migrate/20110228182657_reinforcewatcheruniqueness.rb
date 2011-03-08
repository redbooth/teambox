class Reinforcewatcheruniqueness < ActiveRecord::Migration
  def self.up
    if index_exists?(:watchers, [:user_id, :watchable_id, :watchable_type], :name => 'watchers_uniqueness_index', :unique => true)
      remove_index :watchers, {:name => 'watchers_uniqueness_index'}
    end

    Watcher.connection.execute <<-EOF
      DELETE #{Watcher.table_name}
      FROM #{Watcher.table_name},
        (SELECT MAX(id) as dupid, COUNT(id) as dupcnt, user_id, watchable_id, watchable_type
         FROM #{Watcher.table_name}
         GROUP BY user_id, watchable_id, watchable_type
         HAVING dupcnt > 1) as duplicates
      WHERE #{Watcher.table_name}.id = duplicates.dupid
    EOF

    unless index_exists?(:watchers, [:user_id, :watchable_id, :watchable_type], :name => 'watchers_uniqueness_index', :unique => true)
      add_index :watchers, [:user_id, :watchable_id, :watchable_type], :name => 'watchers_uniqueness_index', :unique => true
    end
  end

  def self.down
    unless index_exists?(:watchers, [:user_id, :watchable_id, :watchable_type], :name => 'watchers_uniqueness_index', :unique => true)
      add_index :watchers, [:user_id, :watchable_id, :watchable_type], :name => 'watchers_uniqueness_index', :unique => true
    end
  end
end
