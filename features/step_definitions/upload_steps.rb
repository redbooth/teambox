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

Given /^"([^\"]*)" has been uploaded to the "([^\"]*)" project(?: into the "([^\"]*)" folder)?$/ do |file_name, project_name, folder_name|
  project = Project.find_by_name!(project_name)
  path = File.join(Rails.root, "spec/fixtures/#{file_name}")
  folder = folder_name ? project.folders.find_by_name!(folder_name) : nil
  if File.exists?(path)
    Factory.create(:upload, {
      :asset => open(path),
      :asset_file_name => file_name,
      :asset_file_size => nil,
      :asset_content_type => nil,
      :project => project,
      :parent_folder => folder
     })
  else
    Factory.create(:upload, :asset_file_name => file_name, :project => project, :parent_folder => folder)
  end
end

When /^I click upload list item for "([^\"]*)" file$/ do |filename|
  page.find(:xpath, "//div[@class = 'header' and .//a[contains(text(),'#{filename}')]]").click
end

When /^I select "([^\"]*)" from target folders list$/ do |folder_name|
  And %(I select "#{folder_name}" from "target_folder_id")
end