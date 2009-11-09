Given /the example sinatra app$/ do
end

When /^I run "([^\"]*)" in the sinatra root$/ do |cmd|
  # Need to run Rails generators first since the siatra app symlinks to the step defs.
  Given "the example rails app is setup with the latest generators"
  When 'I run "rake db:migrate RAILS_ENV=test" in the rails root'
  cmd.gsub!('cucumber', "#{Cucumber::RUBY_BINARY} #{Cucumber::BINARY}")
  Dir.chdir(File.join(root_dir, 'examples', 'sinatra')) do
    @output = `#{cmd}`
  end
end
