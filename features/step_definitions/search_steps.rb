When /^the search index is re(indexed|built)$/ do |action|
  ts_reindex(action == 'built')
  # seems to be necessary before hitting sphinx
  sleep(0.2)
end

When /^I fill in the search box with "(.+)"$/ do |value|
  When(%(I fill in "q" with "#{value}"))
end
