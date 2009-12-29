class Note < RoleRecord
  belongs_to :page
  belongs_to :project
  acts_as_paranoid
    
  formats_attributes :body
    
  attr_accessor :deleted
  attr_accessible :body, :deleted, :name
  
  def user
    User.find_with_deleted(user_id)
  end
  
end