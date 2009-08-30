# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090825190238) do

  create_table :users, :force => true do |t|
    t.string   :login,                     :limit => 40
    t.string   :name,                      :limit => 100, :default => ""
    t.string   :email,                     :limit => 100
    t.string   :crypted_password,          :limit => 40
    t.string   :salt,                      :limit => 40
    t.string   :remember_token,            :limit => 40
    t.datetime :remember_token_expires_at
    t.string   :time_zone,          :default => "Eastern Time (US & Canada)"
    t.string   :language,           :default => "en"
    t.text     :recent_projects
    t.timestamps
  end

  create_table :sessions do |t|
    t.string :session_id, :null => false
    t.text :data
    t.timestamps
  end
  
  create_table :projects do |t|
    t.integer :user_id
    t.string  :name
    t.string  :permalink
    t.timestamps
  end

  create_table :task_lists do |t|
    t.integer :project_id
    t.integer :user_id
    t.integer :page_id, :null => true, :default => nil
    t.string  :name
    t.integer :position
    t.timestamps
  end
  
  create_table :tasks do |t|
    t.integer :project_id
    t.integer :page_id, :null => true, :default => nil
    t.integer :task_list_id
    t.integer :user_id
    t.string  :name
    t.integer :position
    t.timestamps
  end

  create_table :comments do |t|
    t.integer :target_id 
    t.string  :target_type #model name
    t.integer :project_id
    t.integer :user_id
    t.text  :body
    t.text  :body_html
    t.timestamps    
  end
  
  create_table :conversations do |t|
    t.integer :project_id
    t.integer :user_id
    t.string  :name
    t.timestamps
  end
  
  create_table :pages do |t|
    t.integer :project_id
    t.integer :user_id
    t.string  :name
    t.timestamps
  end
  
  create_table :notes do |t|
    t.integer :page_id
    t.integer :project_id
    t.text :body
    t.integer :position
    t.timestamps
  end

  create_table :invitations do |t|
    t.integer :user_id
    t.integer :project_id
    t.string  :email
    t.string  :token
    t.timestamps
  end

  create_table :uploads do |t|
    t.integer  :user_id
    t.integer  :project_id
    t.string   :image_filename
    t.integer  :image_width
    t.integer  :image_height
    t.text     :description, :default => ''
    t.string   :content_type
    t.timestamps
  end

  add_index :sessions, :session_id
  add_index :sessions, :updated_at

  add_index :users, ["login"], :name => "index_users_on_login", :unique => true

  create_table :avatars do |t|
    t.integer  :user_id
    t.integer  :x1
    t.integer  :y1
    t.integer  :x2
    t.integer  :y2
    t.integer  :crop_width
    t.integer  :crop_height
    t.integer  :width
    t.integer  :height
    t.timestamps
  end
  add_index "avatars", ["user_id"], :name => "index_avatars_on_user"

end
