require 'user'

class RenameDeletedUsers < ActiveRecord::Migration
  def self.up
    User.find_only_deleted(:all).each do |user|
      user.rename_as_deleted
    end
  end

  def self.down
    User.find_only_deleted(:all).each do |user|
      user.rename_as_active
    end
  end
end
