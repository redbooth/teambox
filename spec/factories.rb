require 'factory_girl'

Factory.sequence :login do |n|
  "gandhi_#{n}"
end

Factory.sequence :email do |n|
  "gandhi_#{n}@localhost.com"
end

Factory.sequence :name do |n|
  "Teambox ##{n}"
end

Factory.sequence :folder_name do |n|
  "the files #{n}"
end

Factory.sequence :permalink do |n|
  "teambox#{n}"
end

Factory.define :user do |user|
  user.login { Factory.next(:login) }
  user.email { Factory.next(:email) }
  user.first_name 'Andrew'
  user.last_name 'Wiggin'
  user.password 'dragons'
  user.password_confirmation 'dragons'
  user.confirmed_user true
  user.splash_screen false
end

# compatibility with older specs/cukes
Factory.define :confirmed_user, :parent => :user do |user|
end

Factory.define :unconfirmed_user, :parent => :user do |user|
  user.splash_screen true
  user.confirmed_user false
end

Factory.define :mislav, :parent => :user do |user|
  user.login 'mislav'
  user.email 'mislav@fuckingawesome.com'
  user.first_name 'Mislav'
  user.last_name 'Marohnić'
end

Factory.define :organization do |organization|
  organization.name { Factory.next(:name) }
  organization.permalink { Factory.next(:permalink )}
end

Factory.define :person do |person|
  person.association(:project)
  person.association(:user)
end

Factory.define :project do |project|
  project.name { Factory.next(:name) }
  project.association(:user)
  project.association(:organization)
end

Factory.define :ruby_rockstars, :class => 'Project' do |project|
  project.name "Ruby Rockstars"
  project.permalink "ruby_rockstars"
  project.user_id do
    (User.find_by_login('mislav') || Factory(:mislav)).id
  end
  project.association(:organization, :name => "ACME")
end

Factory.define :procial_network, :class => 'Project' do |project|
  project.name "Procial Network"
  project.permalink "procial_network"
  project.public true
  project.user_id do
    (User.find_by_login('mislav') || Factory(:mislav)).id
  end
  project.association(:organization, :name => "ACME")
end

Factory.define :archived_project, :parent => :project do |project|
  project.archived true
end

Factory.define :conversation do |conversation|
  conversation.name 'The Master Plan'
  conversation.body 'Shorter than a New York minute'
  conversation.simple false
  conversation.association(:user)
  conversation.association(:project)
end

Factory.define :simple_conversation, :parent => :conversation do |conversation|
  conversation.name nil
  conversation.simple true
end

Factory.define :task_list_template do |template|
  template.association(:organization)
  template.name 'I will come up with a better name later'
  template.tasks [['First task'],['Second task'],['Third task']]
end

Factory.define :complete_task_list_template, :parent => :task_list_template do |template|
  template.tasks [['First task', 'Bla bla bla'],['Second task','You motherfucker'],['Third task','Booh yah.']]
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

Factory.define :archived_task, :class => Task do |task|
  task.name 'Buy milk'
  task.association(:user)
  task.association(:project)
  task.association(:task_list)
  task.archived true
end

Factory.define :held_task, :class => Task do |task|
  task.name 'Buy milk'
  task.association(:user)
  task.association(:project)
  task.association(:task_list)
  task.status Task::STATUSES[:hold]
end

Factory.define :resolved_task, :class => Task do |task|
  task.name 'Buy milk'
  task.association(:user)
  task.association(:project)
  task.association(:task_list)
  task.status Task::STATUSES[:resolved]
end

Factory.define :rejected_task, :class => Task do |task|
  task.name 'Buy milk'
  task.association(:user)
  task.association(:project)
  task.association(:task_list)
  task.status Task::STATUSES[:rejected]
end

Factory.define :comment do |comment|
  comment.association(:user)
  comment.association(:project)
  comment.target { |comment| comment.project }
  comment.body 'Just finished posting this comment'
end

Factory.define :upload do |upload|
  upload.asset_file_name 'pic.png'
  upload.asset_file_size 42
  upload.asset_content_type 'image/png'
  upload.association(:project)
  upload.association(:user)
end

Factory.define :folder do |folder|
  folder.name {Factory.next(:folder_name)}
  folder.association(:project)
  folder.association(:user)
end

Factory.define :page do |page|
  page.association(:user)
  page.association(:project)
  page.name 'Keys to the Castle'
end

Factory.define :reset_password do |reset_pw|
  reset_pw.reset_code "d1b9547cb3ec99180acfe951c807ec567c8b9252"
  reset_pw.email { Factory.next(:email) }
  reset_pw.association(:user)
end

Factory.define :invitation do |i|
  i.association(:project)
  i.user  { |i| i.project.user }
  i.email { Factory.next(:email) }
end

Factory.define :email_bounce do |f|
  f.email { Factory.next(:email) }
end

Factory.define :google_doc do |d|
  d.title "Very interesting spreadsheet"
  d.url "https://google.com/document/1234"
  d.document_type "spreadsheet"

  d.association :user
  d.association :project
  d.association :comment
end

Factory.define :client_application do |f|
  f.association(:user)
  f.name "MyString"
  f.url "http://test.com"
  f.support_url "http://test.com/support"
  f.callback_url "http://application/callback"
  f.key "one_key"
  f.secret "MyString"
  f.created_at Time.parse("2007-11-17 16:56:51")
  f.updated_at Time.parse("2007-11-17 16:56:51")
end

Factory.define :cucumber_ly, :parent => :client_application do |f|
  f.association(:user)
  f.name "Cucumber.ly"
  f.url "http://cucumber.ly"
  f.support_url "http://cucumber.ly/support"
  f.callback_url "http://cucumber.ly/callback"
  f.created_at Time.parse("2007-11-17 16:56:51")
  f.updated_at Time.parse("2007-11-17 16:56:51")
end

Factory.define :app_link do |d|
  d.provider "google"
  d.app_user_id { Factory.next(:login) }
  d.credentials({'token' => 'xxx', 'secret' => 'blabla'})
  d.custom_attributes({'custom' => 1})

  d.association :user
end

