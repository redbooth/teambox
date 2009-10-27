class CreatePhotoBares < ActiveRecord::Migration
  def self.up
    create_table :photo_bares do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :photo_bares
  end
end
