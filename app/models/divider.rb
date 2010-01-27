class Divider < RoleRecord
  belongs_to :page
  belongs_to :project
  has_one :page_slot, :as => :rel_object
  acts_as_paranoid
  
  before_destroy :clear_slot

  attr_accessor :deleted
  attr_accessible :body, :deleted, :name
  
  def clear_slot
    page_slot.update_attributes(:page_id => nil)
  end

  def slot_view
    'dividers/divider'
  end
end