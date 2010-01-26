class CreatePageSlots < ActiveRecord::Migration
  def self.up
    create_table :page_slots do |t|
      t.integer "page_id",         :limit => 10
      t.integer "rel_object_id",   :limit => 10, :default => 0, :null => false
      t.string  "rel_object_type", :limit => 30
      t.integer "position",        :limit => 10, :default => 0, :null => false
    end
    
    # Make slots for all notes and dividers
    Pages.each do |page|
      page.notes.each do |note|
        PageSlot.create(:page => page, :position => note.position, :rel_object => note)
      end
      
      page.dividers.each do |divider|
        PageSlot.create(:page => page, :position => divider.position, :rel_object => divider)
      end
    end
  end

  def self.down
    drop_table :page_slots
  end
end
