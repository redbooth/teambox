require 'fileutils'

Given /^the (\w+) app is setup with the latest email steps$/ do |app_name|
  app_dir = File.join(root_dir, 'examples',"#{app_name}_root")
  email_specs_path = File.join(app_dir,'features','step_definitions','email_steps.rb')
  latest_specs_path = File.join(root_dir,'lib','generators','email_spec','steps','templates','email_steps.rb')
  FileUtils.rm(email_specs_path) if File.exists?(email_specs_path)
  FileUtils.cp_r(latest_specs_path, email_specs_path)
end

Then /^the (\w+) app should have the email steps in place$/ do |app_name|
  email_specs_path = "#{root_dir}/examples/#{app_name}_root/features/step_definitions/email_steps.rb"
  File.exists?(email_specs_path).should == true
end

Then /^I should see the following summary report:$/ do |expected_report|
  @output.should include(expected_report)
end

Given /^the (\w+) app is setup with the latest generators$/ do |app_name|
  app_dir= File.join(root_dir,'examples',"#{app_name}_root")
  email_specs_path = File.join(app_dir,'features','step_definitions','email_steps.rb')
  FileUtils.rm(email_specs_path) if File.exists?(email_specs_path)

  if app_name == 'rails3'
    #Testing using the gem
    #make sure we are listed in the bundle
    Dir.chdir(app_dir) do
      output =`bundle list`
      output.should include('email_spec')
    end
  else
    FileUtils.mkdir_p("#{app_dir}/vendor/plugins/email_spec")
    FileUtils.cp_r("#{root_dir}/rails_generators","#{app_dir}/vendor/plugins/email_spec/")
    Dir.chdir(app_dir) do
      system "ruby ./script/generate email_spec"
    end
  end
end

When /^I run "([^\"]*)" in the (\w+) app$/ do |cmd, app_name|
  cmd.gsub!('cucumber', "#{Cucumber::RUBY_BINARY} #{Cucumber::BINARY}")
  app_path = File.join(root_dir, 'examples', "#{app_name}_root")
  app_specific_gemfile = File.join(app_path,'Gemfile')
  Dir.chdir(app_path) do
    #hack to fight competing bundles (email specs vs rails3_root's
    if File.exists? app_specific_gemfile
      orig_gemfile = ENV['BUNDLE_GEMFILE']
      ENV['BUNDLE_GEMFILE'] = app_specific_gemfile
      @output = `#{cmd}`
      ENV['BUNDLE_GEMFILE'] = orig_gemfile
    else
      @output = `#{cmd}`
    end
  end
end
