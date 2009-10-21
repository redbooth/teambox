Factory.define :task do |task|
  task.first_name 'Finish all the specs'
end

Factory.define :user do |user|
  user.email 'andrew@localhost.com'
  user.login 'andrew'
  user.name  'Andrew Brown'
  user.password 'testing'
  user.password_confirmation 'testing'
end

Factory.define :project do |project|
  project.name 'Teambox'
  project.permalink 'teambox'
  project.association(:user)
end