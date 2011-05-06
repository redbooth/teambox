class Reinforcewatcheruniqueness < ActiveRecord::Migration
  def self.up
    if index_exists?(:watchers, [:user_id, :watchable_id, :watchable_type], :name => 'watchers_uniqueness_index', :unique => true)
      remove_index :watchers, {:name => 'watchers_uniqueness_index'}
    end

    Watcher.connection.execute <<-EOF
      DELETE 
      FROM #{Watcher.table_name} WHERE id IN
        (SELECT MAX(id) as id
         FROM #{Watcher.table_name}
         GROUP BY user_id, watchable_id, watchable_type
         HAVING COUNT(id) > 1) 
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
