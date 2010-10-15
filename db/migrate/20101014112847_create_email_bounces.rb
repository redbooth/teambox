class CreateEmailBounces < ActiveRecord::Migration
  def self.up
    create_table :email_bounces do |t|
      t.string :email
      t.string :exception_type
      t.string :exception_message
      
      t.timestamps
    end
    
    add_index :email_bounces, :email
    add_index :email_bounces, :created_at
  end

  def self.down
    remove_index :email_bounces, :email
    remove_index :email_bounces, :created_at
    drop_table :email_bounces
  end
end
