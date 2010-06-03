namespace :mail do
  desc "Fetch incoming email"
  task :inbox => :environment do
    require 'emailer/incoming'
    Teambox.fetch_incoming_email
  end
  
  desc "Send daily task reminders"
  task :reminders => :environment do
    require 'user'
    require 'emailer'
    User.send_daily_task_reminders
  end
end

# for Heroku cron add-on
task :cron => ["mail:inbox", "mail:reminders"]
