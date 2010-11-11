class AddDueDateTransition < ActiveRecord::Migration
  def self.up
    add_column :comments, :due_on, :date
    add_column :comments, :previous_due_on, :date
  end

  def self.down
    remove_column :comments, :due_on
    remove_column :comments, :previous_due_on
  end
end
