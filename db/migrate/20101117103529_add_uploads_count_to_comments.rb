class AddUploadsCountToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :uploads_count, :integer, :default => 0
    Comment.update_all "uploads_count = (SELECT COUNT(*) FROM uploads, comments WHERE uploads.comment_id = comments.id AND uploads.deleted_at IS NULL)", "deleted_at IS NULL"
  end

  def self.down
    remove_column :comments, :uploads_count
  end
end
