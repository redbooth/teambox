class CreateWatcherTable < ActiveRecord::Migration
  def self.up
    create_table :watchers do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :watchable_id
      t.string  :watchable_type
      t.timestamps
    end
    add_index :watchers, [:user_id]
    add_index :watchers, [:watchable_id]
    add_index :watchers, [:watchable_type]
    add_index :watchers, [:user_id, :watchable_id, :watchable_type], :name => 'uniqueness_index', :unique => true
    

    [Conversation, Task, TaskList].each do |klass|
      klass.all do |entry|
        entry.add_watchers(YAML::load(entry[:whatchers_ids]))
      end

      remove_column klass.table_name.to_sym, :watchers_ids
    end
  end

  def self.down
    [Conversation, Task, TaskList].each do |klass|
      add_column klass.table_name.to_sym, :watchers_ids, :text

      klass.all do |entry|
        user_ids = Watcher.where(:watchable_type => klass, :watchable_id => entry.id).map(&:user_id)
        entry[:watchers_ids] = user_ids.to_yaml
        entry.save
      end
    end

    drop_table :watchers
  end
end
