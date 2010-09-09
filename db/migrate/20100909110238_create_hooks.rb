class CreateHooks < ActiveRecord::Migration
  def self.up
    create_table :hooks do |t|
      t.integer  :user_id
      t.integer  :project_id 
      t.string   :key
      t.string   :name
      t.text     :message

      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    def self.down
      drop_table :hooks
    end
  end
end