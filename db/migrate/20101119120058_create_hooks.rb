class CreateHooks < ActiveRecord::Migration
  def self.up
    create_table :hooks do |t|
      t.integer  :user_id
      t.integer  :project_id 
      t.string   :token, :unique => true, :null => false
      t.string   :name
      t.text     :message

      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index "hooks", ["token"], :name => "index_hooks_on_key", :unique => true
  end

  def self.down
    drop_table :hooks
  end
end
