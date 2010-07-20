When /^I fill in "([^\"]*)" with line breaks$/ do |field|
  value = "Text with\na break"
  fill_in(field, :with => value)
end
