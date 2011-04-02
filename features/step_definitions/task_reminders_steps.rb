Given /^the email reminders are to be sent at (\d+)$/ do |hour|
  Teambox.config.daily_task_reminder_email_time = hour.to_i
end

When "the daily task reminders go out" do
  User.send_daily_task_reminders
end

Then /I change my locale to (\w+)/ do |locale|
  new_locale = case locale
  when 'français' then :fr
  end

  @current_user.locale = new_locale
  @current_user.save
end