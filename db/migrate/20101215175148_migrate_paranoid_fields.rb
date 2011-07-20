class MigrateParanoidFields < ActiveRecord::Migration
  def self.up
    %w(activities comments conversations dividers google_docs invitations notes organizations pages people projects task_lists tasks teambox_datas uploads users).each do |table|
      add_column table, :deleted, :boolean
      add_index table, [:deleted]
      table.singularize.camelize.constantize.update_all ["deleted = ?", true], "deleted_at IS NOT NULL"
      remove_column table, :deleted_at
    end
  end

  def self.down
    %w(activities comments conversations dividers google_docs invitations notes organizations pages people projects task_lists tasks teambox_datas uploads users).each do |table|
      add_column table, :deleted_at, :datetime
      add_index table, [:deleted_at]
      table.singularize.camelize.constantize.update_all ["deleted_at = ?", Time.now], ["deleted = ?", true]
      remove_column table, :deleted
    end
  end
end
