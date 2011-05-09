When /^I click remove$/ do
  evaluate_script("$$('span.remove a').invoke('forceShow')")
  Then %(I follow "remove")
end