class CreatePageSlots < ActiveRecord::Migration
  def self.up
    create_table :page_slots do |t|
      t.integer "page_id",         :limit => 10
      t.integer "rel_object_id",   :limit => 10, :default => 0, :null => false
      t.string  "rel_object_type", :limit => 30
      t.integer "position",        :limit => 10, :default => 0, :null => false
    end
    
    # Make slots for all notes and dividers
    Page.find(:all).each do |page|
      pos = 0
      
      page.dividers.each do |divider|
        PageSlot.create(:page => page, :position => pos, :rel_object => divider)
        pos += 1
      end
      
      page.notes.each do |note|
        PageSlot.create(:page => page, :position => pos, :rel_object => note)
        pos += 1
      end
    end
  end

  def self.down
    drop_table :page_slots
  end
end
