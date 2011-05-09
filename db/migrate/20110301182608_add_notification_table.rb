class AddNotificationTable < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.integer :person_id
      t.integer :user_id

      t.integer :comment_id
      t.integer :target_id
      t.string  :target_type

      t.boolean :sent, :default => false
      t.boolean :read, :default => false

      t.timestamps
    end

    add_index :notifications, [:user_id, :read]
    add_index :notifications, [:person_id, :sent]
  end

  def self.down
    drop_table :notifications
  end
end
