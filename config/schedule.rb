set :output, "#{RAILS_ROOT}/log/cron.log"

# send out daily reminders
every 1.hour do
  runner "User.send_daily_task_reminders"
end

# rebuild thinking sphynx cache
every 5.minutes do
  rake "ts:rebuild"
end
