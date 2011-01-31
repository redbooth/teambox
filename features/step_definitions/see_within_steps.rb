{
  'in the title' => 'h2',
  'in the watchers list' => '.watching',
  'as a button' => 'a.button, button',
  'in the preview' => '.previewBox'
}.
each do |within, selector|
  Then /^(?:|I )should( not)? see "([^\"]*)" #{within}$/ do |negate, text|
    with_scope(selector) do
      assert page['innerHTML'].include?(text)
    end
  end
end

Then /^I should see an error message: "([^\"]*)"$/ do |text|
  with_scope('.flash-error') do
    Then %(I should see "#{text}")
  end
end

Then /^I should see a notice: "([^\"]*)"$/ do |text|
  with_scope('.flash-notice') do
    Then %(I should see "#{text}")
  end
end
