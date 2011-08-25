class Project
  belongs_to :user
  belongs_to :organization
  accepts_nested_attributes_for :organization

  with_options :dependent => :delete_all do |delete|
    delete.has_many :people
    delete.has_many :task_lists, :conditions => { :page_id => nil }
    delete.has_many :tasks
    delete.has_many :invitations
    delete.has_many :uploads
    delete.has_many :folders
    delete.has_many :notes
    delete.has_many :dividers
    delete.has_many :watcher_tags, :class_name => 'Watcher'
    
    delete.with_options :order => 'id DESC' do |ordered|
      ordered.has_many :conversations
      ordered.has_many :activities
      ordered.has_many :comments
    end
  end
  
  has_many :pages, :dependent => :destroy

  has_many :users, :through => :people
  has_many :admins, :through => :people, :source => :user, :conditions => {'people.role' => Person::ROLES[:admin]}
  
  has_one  :first_comment, :class_name => 'Comment', :as => :target, :order => 'created_at ASC'
  has_many :recent_comments, :class_name => 'Comment', :as => :target, :order => 'created_at DESC', :limit => 2
end
