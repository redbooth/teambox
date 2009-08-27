class AddVersionedTables < ActiveRecord::Migration
  def self.up
    create_table("things") do |t|
      t.column :title, :text
      t.column :price, :decimal, :precision => 7, :scale => 2
      t.column :type, :string
    end
    Thing.create_versioned_table
  end
  
  def self.down
    Thing.drop_versioned_table
    drop_table "things" rescue nil
  end
end