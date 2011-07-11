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

#Given /^a current project has (\d+) levels deep folders tree$/ do |levels|
#  parent_folder_id = nil
#  levels.to_i.times do
#    folder = Factory.create(:folder, :parent_folder_id => parent_folder_id)
#    parent_folder_id = folder.id
#  end
#end

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
