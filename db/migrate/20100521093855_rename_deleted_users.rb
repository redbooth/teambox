class RenameDeletedUsers < ActiveRecord::Migration
  def self.up
    begin
    User.find_only_deleted(:all).each do |user|
      user.rename_as_deleted
    end
    rescue
    end
  end

  def self.down
    begin
    User.find_only_deleted(:all).each do |user|
      user.rename_as_active
    end
    rescue
    end
  end
end
