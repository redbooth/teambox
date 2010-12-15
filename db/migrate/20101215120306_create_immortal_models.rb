class CreateImmortalModels < ActiveRecord::Migration
  def self.up
    create_table :immortal_models do |t|
      t.string :title
      t.integer :value
      t.boolean :deleted, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :immortal_models
  end
end
