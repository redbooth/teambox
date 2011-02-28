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

    [Conversation, Task].each do |klass|
      klass.find_in_batches do |entries|
        if ActiveRecord::Base.configurations[Rails.env]['adapter'] =~ /(mysql)/i
            inserts = []
            entries.each do |entry|

              unless entry[:watchers_ids].nil?
                user_ids = YAML::load(entry[:watchers_ids]).uniq
                user_ids.each do |user_id|
                  inserts.push "(#{user_id}, #{entry.project_id}, #{entry.id}, \"#{klass}\", NOW(), NOW())"
                end
              end

            end
            values = inserts.join(", ")
            sql = " INSERT INTO watchers (`user_id`, `project_id`, `watchable_id`, `watchable_type`, `updated_at`, `created_at`) VALUES " + values
            klass.connection.execute sql

        else
          entries.each do |entry|
            unless entry[:watchers_ids].nil?
              user_ids = YAML::load(entry[:watchers_ids])
              entry.add_watchers( User.where(:id => user_ids) )
            end
          end
        end
      end
    end

    [Conversation, Task, TaskList, Page].each do |klass|
      remove_column klass.table_name.to_sym, :watchers_ids if klass.column_names.include? 'watchers_ids'
    end
  end

  def self.down
    [Conversation, Task].each do |klass|
      add_column klass.table_name.to_sym, :watchers_ids, :text
      klass.reset_column_information

      klass.find_in_batches do |entries|
        entries.each do |entry|
          user_ids = Watcher.where(:watchable_type => klass, :watchable_id => entry.id).map(&:user_id)
          entry[:watchers_ids] = user_ids.to_yaml
          entry.save(false)
        end
      end
    end

    drop_table :watchers
  end
end
