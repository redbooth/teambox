# When running Whenever, the environment should be specified with --set environment
ENV['RAILS_ENV'] = environment || 'production'

require File.join(File.dirname(__FILE__), "environment")

set :output, File.join(Rails.root, "log", "cron.log")

every 1.hour do
  rake "mail:reminders", :environment => :production
end

every 1.minutes do
  rake "mail:inbox", :environment => :production
end

every 30.minutes do
  rake "ts:rebuild", :environment => :production
end