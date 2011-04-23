Then /^(?:|I )authenticate on "([^"]*)" with "([^"]*)" account$/ do |service, name|
  VCR.use_cassette("authentication_#{service.underscore}", :erb => {:name => name.downcase}, :match_requests_on => [:method, :path]) do
    visit("/auth/#{service.underscore}")
    visit("/auth/#{service.underscore}/callback")
  end
end

Then /the fields "([^"]*)" should contain "([^"]*)"$/ do |fields, values|
  field = fields.split(',')
  value = values.split(',')
  (0..field.size-1).each do |index|
    Then %(the "#{field[index]}" field should contain "#{value[index]}")
  end
end