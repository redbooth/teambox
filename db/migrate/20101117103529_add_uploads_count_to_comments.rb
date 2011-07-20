class AddUploadsCountToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :uploads_count, :integer, :default => 0
    case ActiveRecord::Base.configurations[Rails.env]['adapter']
    when 'postgresql'
      Comment.update_all "uploads_count = (SELECT COUNT(*) FROM uploads,comments WHERE uploads.comment_id = comments.id AND uploads.deleted_at IS NULL)", "deleted_at IS NULL"
    else
      Comment.update_all "uploads_count = (SELECT COUNT(*) FROM uploads WHERE uploads.comment_id = comments.id AND uploads.deleted_at IS NULL)", "deleted_at IS NULL"
    end
  end

  def self.down
    remove_column :comments, :uploads_count
  end
end
