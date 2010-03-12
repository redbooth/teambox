set :output, "#{RAILS_ROOT}/log/cron.log"

# send out daily reminders
every 1.hour do
  runner "User.send_daily_task_reminders", :environment => :production
end

every 1.minutes do
  rake "mail:inbox", :environment => :production
end
