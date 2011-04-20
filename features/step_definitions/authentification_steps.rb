Then /^(?:|I )authenticate on "([^"]*)" with "([^"]*)" account$/ do |service, name|
  VCR.use_cassette("authentication_#{service.underscore}", :erb => {:name => name.downcase} ) do
    visit("/auth/#{service.underscore}")
    visit("/auth/#{service.underscore}/callback")
  end
end

Then /the fields "([^"]*)" should contain "([^"]*)"$/ do |fields, values|
  field = fields.split(',')
  value = values.split(',')
  (0..field.size).each do |i|
    Then %(the "#{field[i]}" field should contain "#{value[i]}")
  end
end