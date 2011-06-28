Given /^I created? (\d+) pages? in the "([^\"]*)" project/ do |n,project_name|
  project = Project.find_by_name(project_name)
  n.to_i.times { project.new_page(@current_user, :name => "Some page for the #{project_name} project").save! }
end

Given /^the (p[a-z]+ )?project page "([^\"]*)" exists(?: in "([^\"]*)")?(?: with the body "([^\"]*)"( that is huge)?)?$/ do |priv_type, name, project_name, body_content, huge_content|
  priv_type = (priv_type||'').strip == 'private'
  project = project_name ? Project.find_by_name(project_name) : @current_project
  @page = project.pages.find_by_name(name) || project.new_page(@current_user, {:name => name})
  @page.is_private = true if priv_type
  @page.save!
  note = @page.build_note({:name => 'The first note'}).tap do |n|
    n.updated_by = @page.user
    n.body = body_content
    n.body = body_content * 100 if huge_content
    n.save!
  end
end

Given /^(@.+) created the (p[a-z]+ )?project page "([^\"]*)"(?: in "([^\"]*)")?$/ do |user_name, priv_type, name, project_name|
  priv_type = (priv_type||'').strip == 'private'
  project = project_name ? Project.find_by_name(project_name) : @current_project
  user = User.find_by_login(user_name.gsub('@',''))
  @page = project.pages.find_by_name(name) || project.new_page(user, {:name => name})
  @page.user = user
  @page.is_private = true if priv_type
  @page.save
end

Given /^the page "([^\"]+)" is watched by (@.+)$/ do |name, users|
  page = Page.find_by_name(name)
  
  each_user(users) do |user|
    page.add_watcher(user)
  end
  
  page.save(:validate => false)
end
