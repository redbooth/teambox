class AddAuthTokenToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :authentication_token, :string
    add_index "users", ["authentication_token"], :name => "index_users_on_auth_token", :unique => true
  end

  def self.down
    remove_column :users, :authentication_token
    remove_index "users", "auth_token"
  end
end
