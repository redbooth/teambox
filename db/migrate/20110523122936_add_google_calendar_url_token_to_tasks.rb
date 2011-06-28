class AddGoogleCalendarUrlTokenToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :google_calendar_url_token, :string
  end

  def self.down
    remove_column :tasks, :google_calendar_url_token
  end
end