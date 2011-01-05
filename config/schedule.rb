set :output, "#{Rails.root}/log/cron.log"

every 1.hour do
  rake "mail:reminders", :environment => :production
end

every 1.minutes do
  rake "mail:inbox", :environment => :production
end

every 30.minutes do
  rake "ts:rebuild", :environment => :production
end
