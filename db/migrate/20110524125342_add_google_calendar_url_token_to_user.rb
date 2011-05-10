class AddGoogleCalendarUrlTokenToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :google_calendar_url_token, :string
  end

  def self.down
    remove_column :users, :google_calendar_url_token
  end
end