Factory.define :task do |task|
  task.first_name 'Finish all the specs'
end

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
  user.name  'Andrew Brown'
  user.password 'testing'
  user.password_confirmation 'testing'
end

Factory.define :project do |project|
  project.name { Factory.next(:name) }
  project.association(:user)
end