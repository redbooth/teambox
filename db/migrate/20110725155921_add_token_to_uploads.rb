class AddTokenToUploads < ActiveRecord::Migration
  def self.up
    add_column :uploads, :token, :string, :limit => 16
  end

  def self.down
    remove_column :uploads, :token
  end
end
