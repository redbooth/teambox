class AddConvertedFlagToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :record_conversion_id, :integer
    add_column :tasks, :record_conversion_type, :string
  end

  def self.down
    remove_column :tasks, :record_conversion_id
    remove_column :tasks, :record_conversion_type
  end
end
