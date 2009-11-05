Factory.define :task do |task|
  task.first_name 'Finish all the specs'
end

Factory.sequence :login do |n|
  "shweet_#{n}"
end

Factory.sequence :email do |n|
  "shweet_#{n}@localhost.com"
end

Factory.sequence :name do |n|
  "Teambox ##{n}"
end

Factory.define :user do |user|
  user.login { Factory.next(:login) }
  user.email { Factory.next(:email) }
  user.first_name 'Andrew'
  user.last_name 'Brown'
  user.password 'lobster'
  user.password_confirmation 'lobster'
end

Factory.define :project do |project|
  project.name { Factory.next(:name) }
  project.association(:user)
end

Factory.define :comment do |comment|
  comment.association(:user)
  comment.association(:project)
  comment.body 'Just finished posting this comment'
end