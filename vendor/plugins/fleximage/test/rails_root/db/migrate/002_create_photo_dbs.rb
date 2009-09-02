class CreatePhotoDbs < ActiveRecord::Migration
  def self.up
    create_table :photo_dbs do |t|
      t.string :image_filename
      t.integer :image_width
      t.integer :image_height
      t.binary :image_file_data

      t.timestamps
    end
  end

  def self.down
    drop_table :photo_dbs
  end
end
