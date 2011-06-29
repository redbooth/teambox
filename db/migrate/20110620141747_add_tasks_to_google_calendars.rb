class AddTasksToGoogleCalendars < ActiveRecord::Migration
  def self.up
    Task.where(Task.arel_table[:assigned_id].not_eq(nil)).find_each do |task|
      if task.assigned.try(:user) || !task.google_calendar_url_token.blank?
        begin
          event = task.force_google_calendar_event_creation!

          puts "Task: #{task.id}. #{task.name} added? #{!event.nil?}"
          puts "\t#{event['alternateLink']}" if event && event['alternateLink']
        rescue => e
          puts "Error with task #{task.id} #{e.message}"
        end
      end
    end
  end

  def self.down
    Task.where(Task.arel_table[:google_calendar_url_token].not_eq(nil)).find_each do |task|
      result = task.delete_google_calendar_event!
      puts "Removing Google Cal: #{task.id}. #{task.name} - #{result}"
    end
  end
end
