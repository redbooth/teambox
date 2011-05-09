namespace :mail do
  desc "Fetch incoming email"
  task :inbox => :environment do
    Teambox.fetch_incoming_email
  end
  
  desc "Send daily task reminders"
  task :reminders => :environment do
    User.send_daily_task_reminders
  end

  desc "Send notification digest"
  task :digest => :environment do
    Person.send_all_digest
  end
end

# for Heroku cron add-on
task :cron => ["mail:inbox", "mail:reminders", "mail:digest"]
