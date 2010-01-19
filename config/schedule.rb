set :output, "#{RAILS_ROOT}/log/cron.log"

every 1.day, :at => '00:01 am' do
  runner "User.send_daily_task_reminders"
end
