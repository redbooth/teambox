set :output, "#{RAILS_ROOT}/log/cron.log"

every 1.hour do
  rake "mail:reminders", :environment => :production
end

every 1.minutes do
  rake "mail:inbox", :environment => :production
end
