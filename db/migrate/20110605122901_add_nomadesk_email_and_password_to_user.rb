class AddNomadeskEmailAndPasswordToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :nomadesk_password, :string
  end

  def self.down
    remove_column :users, :nomadesk_password
  end
end