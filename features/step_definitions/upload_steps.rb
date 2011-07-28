require 'tempfile'

When /^(?:|I )attach a (\d+) ?MB file to "([^\"]*)"(?: within "([^\"]*)")?$/ do |size, field, selector|
  with_scope(selector) do
    file = Tempfile.new 'cucumber_upload'
    (size.to_i * 1024).times do
      file << ('x' * 1024) << "\n"
    end
    file.close
    attach_file(field, file.path)
  end
end

Given /^"([^\"]*)" has been uploaded to the "([^\"]*)" project$/ do |file_name, project_name|
  project = Project.find_by_name(project_name)
  Factory.create(:upload, :asset_file_name => file_name, :project => project)
end

When /^I click upload list item for "([^\"]*)" file$/ do |filename|
  page.find(:xpath, "//div[@class = 'header' and .//a[contains(text(),'#{filename}')]]").click
end