Then /^I authenticate with "([^"]*)"$/ do |service|
  VCR.use_cassette("authentication_#{service.underscore}") do
    visit("/auth/#{service.underscore}")
    visit("/auth/#{service.underscore}/callback")
  end
end