Then /^I should see New Folder form$/ do
  with_css_scope('form#new_folder_form') do
     find(:xpath, '//input[@type="text" and @value="Enter a folder name"]')
     find(:xpath, '//input[@type="submit" and @value="Create folder"]')
  end
end

When /^(?:|I )fill in the form name with "([^\"]*)"$/ do |value|
  with_css_scope('form#new_folder_form') do
    find(:xpath, '//input[@type="text" and @value="Enter a folder name"]').set(value)
  end
end

Given /^there is a folder called "([^\"]*)" in a current project$/ do |name|
  @current_project.folders.find_by_name(name) || Factory(:folder, :name => name, :project => @current_project)
end

Given /^a current project has nested folders$/ do |folders_table|
  folder = nil
  folders_table.hashes.each do |folder_params|
    folder_params.merge!({:project_id => @current_project.id, :user_id => @current_user.id})
    folder_params[:parent_folder_id] = folder.id unless folder.nil?
    folder = Factory.create(:folder, folder_params)
  end
end

When /^I enter "([^"]*)" folder$/ do |name|
  find(:xpath, "//a[text()='#{name}']").click
end

When /^I click upload list item for "([^\"]*)" folder$/ do |foldername|
  page.find(:xpath, "//div[@class = 'header' and .//a[contains(text(),'#{foldername}')]]").click
end