Given /^the following conversation? with associations exists?:?$/ do |table|
  table.hashes.each do |hash|
    Factory(:conversation,
      :name => hash[:name],
      :user => User.find_by_login(hash[:user]),
      :project => Project.find_by_name(hash[:project])
    )
  end
end