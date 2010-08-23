class RemoveDefaultFromCommentsStatus < ActiveRecord::Migration
  def self.up
    change_column_default :comments, :status, nil
    change_column_default :comments, :previous_status, nil
  end

  def self.down
    change_column_default :comments, :previous_status, 0
    change_column_default :comments, :status, 0
  end
end
