Then /^I should see the following summary report:$/ do |expected_report|
  @output.should include(expected_report)
end
