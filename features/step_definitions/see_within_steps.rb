{
  'in the title' => 'h2',
  'in the watchers list' => '.watching',
  'as a button' => 'a.button, button',
  'in the preview' => '.previewBox'
}.
each do |within, selector|
  Then /^(?:|I )should( not)? see "([^\"]*)" #{within}$/ do |negate, text|
    with_scope(selector) do
      if content = page['innerHTML']
        assert negate ? !content.include?(text) : content.include?(text)
      else
        Then %(I should#{negate} see "#{text}")
      end
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
