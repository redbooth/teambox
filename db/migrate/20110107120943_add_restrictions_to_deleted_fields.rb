class AddRestrictionsToDeletedFields < ActiveRecord::Migration
  def self.up
    %w(activities comments conversations dividers google_docs invitations notes organizations pages people projects task_lists tasks teambox_datas uploads users).each do |table|
      change_column table, :deleted, :boolean, :default => false, :null => false
    end
  end

  def self.down
    %w(activities comments conversations dividers google_docs invitations notes organizations pages people projects task_lists tasks teambox_datas uploads users).each do |table|
      change_column table, :deleted, :boolean, :default => nil, :null => true
    end
  end
end
