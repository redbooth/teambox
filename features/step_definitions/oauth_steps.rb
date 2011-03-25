
Given /^I have an OAuth access token(?: for "([^"]*)")?$/ do |client_name|
  client = ClientApplication.find_by_name(client_name || 'Cucumber.ly') || Factory.create(:cucumber_ly)
  token = Oauth2Token.create!(:scope => [:offline_access], :client_application => client, :user => @current_user)
end

Given /^I should have no OAuth access tokens/ do
  assert(Oauth2Token.find(:all, :conditions => {:user_id => @current_user.id}).length == 0)
end