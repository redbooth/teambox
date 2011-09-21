# When running Whenever, the environment should be specified with --set environment
ENV['RAILS_ENV'] = environment || 'production'

require File.join(File.dirname(__FILE__), "environment")

set :output, File.join(Rails.root, "log", "cron.log")

every 1.hour do
  rake "mail:reminders", :environment => :production
end

if Teambox.config.allow_incoming_email and Teambox.config.incoming_email_settings[:type].downcase != 'pipe'
  every 1.minutes do
    rake "mail:inbox", :environment => :production
  end
end

every 15.minutes do
  rake "mail:digest", :environment => :production
end

every 30.minutes do
  rake "ts:rebuild", :environment => :production
end
