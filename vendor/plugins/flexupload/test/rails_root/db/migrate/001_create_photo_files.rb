class CreatePhotoFiles < ActiveRecord::Migration
  def self.up
    create_table :photo_files do |t|
      t.string :image_filename
      t.integer :image_width
      t.integer :image_height

      t.timestamps
    end
  end

  def self.down
    drop_table :photo_files
  end
end
