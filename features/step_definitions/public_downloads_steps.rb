When /^I visit public download page with invalid token$/ do
  visit public_download_file_path(:token => 'tHiSt0keniSwr0ng')
end
