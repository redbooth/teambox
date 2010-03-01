set :output, "#{RAILS_ROOT}/log/cron.log"

# send out daily reminders
every 1.hour do
  runner "User.send_daily_task_reminders"
end

# rebuild thinking sphynx cache
every 5.minutes do
  rake "ts:rebuild"
end

every 1.minutes do
  #FIXME: make the 'inbox' script into a rake task so that it's not installation specific
  command "/data/Teambox2/current/script/inbox"
end
