class InitialSchema < ActiveRecord::Migration
  def self.up
    return if connection.tables.include?('groups')
    
    create_table "activities" do |t|
      t.integer  "user_id"
      t.integer  "project_id"
      t.integer  "target_id"
      t.string   "target_type"
      t.string   "action"
      t.string   "comment_type"
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "activities", ["created_at"], :name => "index_activities_on_created_at"
    add_index "activities", ["deleted_at"], :name => "index_activities_on_deleted_at"
    add_index "activities", ["project_id"], :name => "index_activities_on_project_id"

    create_table "addresses" do |t|
      t.integer "card_id"
      t.string  "street"
      t.string  "city"
      t.string  "state"
      t.string  "zip"
      t.string  "country"
      t.integer "account_type", :default => 0
    end

    create_table "announcements" do |t|
      t.integer "user_id"
      t.integer "comment_id"
    end

    create_table "cards" do |t|
      t.integer "user_id"
      t.boolean "public",  :default => false
    end

    create_table "comments" do |t|
      t.integer  "target_id"
      t.string   "target_type"
      t.integer  "project_id"
      t.integer  "user_id"
      t.text     "body"
      t.text     "body_html"
      t.float    "hours"
      t.boolean  "billable"
      t.integer  "status",               :default => 0
      t.integer  "previous_status",      :default => 0
      t.integer  "assigned_id"
      t.integer  "previous_assigned_id"
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "comments", ["deleted_at"], :name => "index_comments_on_deleted_at"
    add_index "comments", ["target_type", "target_id", "user_id"], :name => "index_comments_on_target_type_and_target_id_and_user_id"

    create_table "comments_read" do |t|
      t.integer "target_id"
      t.string  "target_type"
      t.integer "user_id"
      t.integer "last_read_comment_id"
    end

    add_index "comments_read", ["target_type", "target_id", "user_id"], :name => "index_comments_read_on_target_type_and_target_id_and_user_id"

    create_table "conversations" do |t|
      t.integer  "project_id"
      t.integer  "user_id"
      t.string   "name"
      t.integer  "last_comment_id"
      t.integer  "comments_count", :default => 0, :null => false
      t.text     "watchers_ids"
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "conversations", ["deleted_at"], :name => "index_conversations_on_deleted_at"
    add_index "conversations", ["project_id"], :name => "index_conversations_on_project_id"

    create_table "dividers" do |t|
      t.integer  "page_id"
      t.integer  "project_id"
      t.string   "name"
      t.integer  "position"
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "email_addresses" do |t|
      t.integer "card_id"
      t.string  "name"
      t.integer "account_type", :default => 0
    end

    create_table "emails" do |t|
      t.string   "from"
      t.string   "to"
      t.integer  "last_send_attempt", :default => 0
      t.text     "mail"
      t.datetime "created_on"
    end

    create_table "ims" do |t|
      t.integer "card_id"
      t.string  "name"
      t.integer "account_im_type", :default => 0
      t.integer "account_type",    :default => 0
    end

    create_table "invitations" do |t|
      t.integer  "user_id"
      t.integer  "project_id"
      t.integer  "role",           :default => 2
      t.integer  "group_id"
      t.string   "email"
      t.integer  "invited_user_id"
      t.string   "token"
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "notes" do |t|
      t.integer  "page_id"
      t.integer  "project_id"
      t.string   "name"
      t.text     "body"
      t.text     "body_html"
      t.integer  "position"
      t.integer  "last_comment_id"
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "notes", ["deleted_at"], :name => "index_notes_on_deleted_at"

    create_table "page_slots" do |t|
      t.integer "page_id"
      t.integer "rel_object_id",                 :default => 0, :null => false
      t.string  "rel_object_type", :limit => 30
      t.integer "position",                      :default => 0, :null => false
    end

    create_table "pages" do |t|
      t.integer  "project_id"
      t.integer  "user_id"
      t.string   "name"
      t.text     "description"
      t.integer  "last_comment_id"
      t.text     "watchers_ids"
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "pages", ["deleted_at"], :name => "index_pages_on_deleted_at"
    add_index "pages", ["project_id"], :name => "index_pages_on_project_id"

    create_table "people" do |t|
      t.integer  "user_id"
      t.integer  "project_id"
      t.integer  "source_user_id"
      t.datetime "deleted_at"
      t.string   "permissions"
      t.integer  "role",           :default => 2
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "people", ["user_id", "project_id"], :name => "index_people_on_user_id_and_project_id"

    create_table "phone_numbers" do |t|
      t.integer "card_id"
      t.string  "name"
      t.integer "account_type", :default => 0
    end

    create_table "projects" do |t|
      t.integer  "group_id", :default => nil
      t.integer  "user_id"
      t.string   "name"
      t.string   "permalink"
      t.integer  "last_comment_id"
      t.integer  "comments_count",  :default => 0, :null => false
      t.boolean  "archived",        :default => false
      t.boolean  "tracks_time",     :default => false
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "projects", ["deleted_at"], :name => "index_projects_on_deleted_at"
    add_index "projects", ["permalink"], :name => "index_projects_on_permalink"

    create_table "reset_passwords" do |t|
      t.integer  "user_id"
      t.string   "reset_code"
      t.datetime "expiration_date"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "sessions" do |t|
      t.string   "session_id", :default => "", :null => false
      t.text     "data"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
    add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

    create_table "social_networks" do |t|
      t.integer "card_id"
      t.string  "name"
      t.integer "account_network_type", :default => 0
      t.integer "account_type",         :default => 0
    end

    create_table "task_lists" do |t|
      t.integer  "project_id"
      t.integer  "user_id"
      t.integer  "page_id"
      t.string   "name"
      t.integer  "position"
      t.integer  "last_comment_id"
      t.integer  "comments_count",       :default => 0, :null => false
      t.text     "watchers_ids"
      t.boolean  "archived",             :default => false
      t.datetime "deleted_at"
      t.integer  "archived_tasks_count", :default => 0, :null => false
      t.integer  "tasks_count",          :default => 0, :null => false
      t.datetime "completed_at"
      t.date     "start_on"
      t.date     "finish_on"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "task_lists", ["deleted_at"], :name => "index_task_lists_on_deleted_at"
    add_index "task_lists", ["project_id"], :name => "index_task_lists_on_project_id"

    create_table "tasks" do |t|
      t.integer  "project_id"
      t.integer  "page_id"
      t.integer  "task_list_id"
      t.integer  "user_id"
      t.string   "name"
      t.integer  "position"
      t.integer  "comments_count",  :default => 0, :null => false
      t.integer  "last_comment_id"
      t.text     "watchers_ids"
      t.integer  "assigned_id"
      t.integer  "status",          :default => 0
      t.date     "due_on"
      t.datetime "completed_at"
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "tasks", ["deleted_at"], :name => "index_tasks_on_deleted_at"
    add_index "tasks", ["project_id"], :name => "index_tasks_on_project_id"
    add_index "tasks", ["task_list_id"], :name => "index_tasks_on_task_list_id"

    create_table "uploads" do |t|
      t.integer  "user_id"
      t.integer  "project_id"
      t.integer  "comment_id"
      t.integer  "page_id"
      t.text     "description"
      t.string   "asset_file_name"
      t.string   "asset_content_type"
      t.integer  "asset_file_size"
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "uploads", ["comment_id"], :name => "index_uploads_on_comment_id"

    create_table "users" do |t|
      t.string   "login",                       :limit => 40
      t.string   "first_name",                  :limit => 20,  :default => ""
      t.string   "last_name",                   :limit => 20,  :default => ""
      t.text     "biography",                                  :default => "", :null => false
      t.string   "email",                       :limit => 100
      t.string   "crypted_password",            :limit => 40
      t.string   "salt",                        :limit => 40
      t.string   "remember_token",              :limit => 40
      t.datetime "remember_token_expires_at"
      t.string   "time_zone",                                  :default => "Eastern Time (US & Canada)"
      t.string   "language",                                   :default => "en"
      t.string   "first_day_of_week",                          :default => "sunday"
      t.integer  "invitations_count",                          :default => 0,   :null => false
      t.string   "login_token",                 :limit => 40
      t.datetime "login_token_expires_at"
      t.boolean  "welcome",                                    :default => false
      t.boolean  "confirmed_user",                             :default => false
      t.integer  "last_read_announcement"
      t.datetime "deleted_at"
      t.string   "rss_token",                   :limit => 40
      t.boolean  "admin",                                      :default => false
      t.integer  "comments_count",                             :default => 0,     :null => false
      t.boolean  "notify_mentions",                            :default => true
      t.boolean  "notify_conversations",                       :default => true
      t.boolean  "notify_task_lists",                          :default => true
      t.boolean  "notify_tasks",                               :default => true
      t.string   "avatar_file_name"
      t.string   "avatar_content_type"
      t.integer  "avatar_file_size"
      t.integer  "invited_by_id"
      t.integer  "invited_count",                              :default => 0,     :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "wants_task_reminder",                        :default => true
      t.text     "recent_projects_ids"
      t.string   "feature_level",                              :default => ""
      t.string   "spreedly_token",                             :default => ""
    end

    add_index "users", ["deleted_at"], :name => "index_users_on_deleted_at"
    add_index "users", ["login"], :name => "index_users_on_login", :unique => true

    create_table "websites" do |t|
      t.integer "card_id"
      t.string  "name"
      t.integer "account_type", :default => 0
    end

    create_table "groups" do |t|
      t.string   "name",                      :limit => 40
      t.text     "description"
      t.string   "permalink",                 :limit => 40
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.integer  "logo_file_size"
    end

    create_table "groups_users", :id => false do |t|
      t.integer "group_id"
      t.integer "user_id"
    end
  end

  def self.down
  end
end
