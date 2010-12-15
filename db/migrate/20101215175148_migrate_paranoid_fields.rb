class MigrateParanoidFields < ActiveRecord::Migration
  def self.up
    %w(activities comments conversations dividers google_docs invitations notes organizations pages people projects task_lists tasks teambox_datas uploads users).each do |table|
      remove_column table, :deleted_at
      add_column table, :deleted, :boolean
      add_index table, [:deleted]
    end
  end

  def self.down
    %w(activities comments conversations dividers google_docs invitations notes organizations pages people projects task_lists tasks teambox_datas uploads users).each do |table|
      remove_column table, :deleted
      add_column table, :deleted_at, :datetime
      add_index table, [:deleted_at]
    end
  end
end
