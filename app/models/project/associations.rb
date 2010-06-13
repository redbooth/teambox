class Project
  belongs_to :user
  belongs_to :group

  with_options :dependent => :destroy do |project|
    project.has_many :people
    project.has_many :task_lists, :conditions => { :page_id => nil }
    project.has_many :tasks
    project.has_many :uploads
    project.has_many :invitations
    project.has_many :hooks
  end
  
  with_options :dependent => :destroy, :order => 'id DESC' do |project|
    project.has_many :conversations
    project.has_many :pages
    project.has_many :comments
    project.has_many :activities
  end

  has_many :users, :through => :people, :order => 'users.updated_at DESC'
end