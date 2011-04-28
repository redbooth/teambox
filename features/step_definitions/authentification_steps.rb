Then /^(?:|I )authenticate on "([^"]*)" with "([^"]*)" account$/ do |service, name|
  OmniAuth.config.test_mode = true
  auth_hash = YAML.load(File.open("features/fixtures/authentication_#{service.underscore}.yml").read)
  OmniAuth.config.mock_auth[service.underscore.to_sym] = auth_hash
  visit("/auth/#{service.underscore}")
end

Then /the fields "([^"]*)" should contain "([^"]*)"$/ do |fields, values|
  field = fields.split(',')
  value = values.split(',')
  (0..field.size-1).each do |index|
    Then %(the "#{field[index]}" field should contain "#{value[index]}")
  end
end