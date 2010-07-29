When /^the search index is re(indexed|built)$/ do |action|
  ts_reindex(action == 'built')
  # seems to be necessary before hitting sphinx
  sleep(0.2)
end
