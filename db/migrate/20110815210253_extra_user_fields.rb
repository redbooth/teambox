class ExtraUserFields < ActiveRecord::Migration
  def self.up
    add_column :users, :email_login_token, :string, :default => nil
  end

  def self.down
    remove_column :users, :email_login_token
  end
end
