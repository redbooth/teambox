require 'fileutils'

Given /^the example rails app is setup with the latest generators$/ do

  email_specs_path = "#{root_dir}/examples/rails_root/features/step_definitions/email_steps.rb"
  FileUtils.rm(email_specs_path) if File.exists?(email_specs_path)
  FileUtils.mkdir_p("#{root_dir}/examples/rails_root/vendor/plugins/email_spec")
  FileUtils.cp_r("#{root_dir}/rails_generators", "#{root_dir}/examples/rails_root/vendor/plugins/email_spec/")

  Dir.chdir(File.join(root_dir, 'examples', 'rails_root')) do
    system "./script/generate email_spec"
  end

end

When /^I run "([^\"]*)" in the rails root$/ do |cmd|
  cmd.gsub!('cucumber', "#{Cucumber::RUBY_BINARY} #{Cucumber::BINARY}")
  Dir.chdir(File.join(root_dir, 'examples', 'rails_root')) do
    @output = `#{cmd}`
  end
end
