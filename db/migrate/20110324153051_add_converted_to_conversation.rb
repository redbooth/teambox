class AddConvertedToConversation < ActiveRecord::Migration
  def self.up
    add_column :conversations, :converted_to, :integer
  end

  def self.down
    remove_column :conversations, :converted_to
  end
end
