class PageSlot < ActiveRecord::Base
  belongs_to :page
  belongs_to :rel_object, :polymorphic => true
  
  # Note: to restore, lookup page_id in rel_object
  def invalidate_page
    self.page_id = nil
  end
  
  #acts_as_paranoid
end
