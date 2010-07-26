class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations do |t|
      t.string :name
      t.string :permalink, :null => false
      t.string :language, :default => 'en'
      t.string :time_zone, :default => "Eastern Time (US & Canada)"
      t.string :domain
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :organizations
  end
end
