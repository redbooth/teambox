Factory.sequence :login do |n|
  "gandhi_#{n}"
end

Factory.sequence :email do |n|
  "gandhi_#{n}@localhost.com"
end

Factory.sequence :name do |n|
  "Teambox ##{n}"
end

Factory.define :user do |user|
  user.login { Factory.next(:login) }
  user.email { Factory.next(:email) }
  user.first_name 'Andrew'
  user.last_name 'Wiggin'
  user.password 'dragons'
  user.password_confirmation 'dragons'
end

Factory.define :person do |person|
  person.association(:project)
  person.association(:user)
end

Factory.define :project do |project|
  project.name { Factory.next(:name) }
  project.association(:user)
end

Factory.define :conversation do |conversation|
  conversation.name 'The Master Plan'
  conversation.association(:user)
  conversation.association(:project)
end

Factory.define :task_list do |task_list|
  task_list.name 'Buy Groceries'
  task_list.association(:user)
  task_list.association(:project)
end

Factory.define :task do |task|
  task.name 'Buy milk'
  task.association(:user)
  task.association(:project)
  task.association(:task_list)
end

Factory.define :comment do |comment|
  comment.association(:user)
  comment.association(:project)
  comment.body 'Just finished posting this comment'
end

Factory.define :page do |page|
  page.association(:user)
  page.association(:project)
  page.name 'Keys to the Castle'
end

Factory.define :mislav, :class => 'User' do |user|
  user.login 'mislav'
  user.email 'mislav@fuckingawesome.com'
  user.first_name 'Mislav'
  user.last_name 'Marohnić'
  user.password 'makeabarrier'
  user.password_confirmation 'makeabarrier'
  user.confirmed_user true  
end

Factory.define :geoffrey, :class => 'User' do |user|
  user.login 'geoffrey'
  user.email 'geoffrey@peepcode.com'
  user.first_name 'Geoffrey'
  user.last_name 'Grosenbach'
  user.password 'smoothlistening'
  user.password_confirmation 'smoothlistening'
  user.confirmed_user true  
end

Factory.define :ruby_rockstars, :class => 'Project' do |project|
  project.name "Ruby Rockstars"
  project.permalink "ruby_rockstars"
  project.user_id do
    (User.find_by_login('mislav') || Factory(:mislav)).id
  end
end
