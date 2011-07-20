class AddCredentialsToAppLinks < ActiveRecord::Migration
  def self.up
    add_column :app_links, :access_token, :string
    add_column :app_links, :access_secret, :string
  end

  def self.down
    remove_column :app_links, :access_token
    remove_column :app_links, :access_secret
  end
end