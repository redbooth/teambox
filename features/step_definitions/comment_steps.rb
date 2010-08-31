When /^(?:|I )fill in the comment box with "([^\"]*)"(?: within "([^\"]*)")?$/ do |value, selector|
  with_scope(selector) do
    xpath = Capybara::XPath.append('//textarea[contains(@name, "[body]")]')
    locate(:xpath, xpath, "cannot fill in: no comment textarea found").set(value)
  end
end

When /^I fill in the comment box with line breaks$/ do
  text = "Text with\na break"
  xpath = Capybara::XPath.append('//textarea[contains(@name, "[body]")]')
  locate(:xpath, xpath, "cannot fill in: no comment textarea found").set(text)
end
