class Note < RoleRecord
  belongs_to :page
  belongs_to :project
  has_one :page_slot, :as => :rel_object
  acts_as_paranoid
  
  before_destroy :clear_slot
    
  formats_attributes :body
    
  attr_accessor :deleted
  attr_accessible :body, :deleted, :name
  
  def clear_slot
    page_slot.update_attributes(:page_id => nil)
  end
  
  def slot_view
    'notes/note'
  end
  
  def to_s
    name
  end
  
  def user
    User.find_with_deleted(user_id)
  end
  
end