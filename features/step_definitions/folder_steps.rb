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