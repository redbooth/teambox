class PageSlot < ActiveRecord::Base
  belongs_to :page
  belongs_to :rel_object, :polymorphic => true
end
