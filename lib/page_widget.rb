module PageWidget
  attr_accessor :slot_insert
  
  def save_slot
    @slot_insert ||= {:footer => false, :before => false}
    self.page_slot ||= self.page.new_slot(@slot_insert[:id], @slot_insert[:before], self)

    if @slot_insert[:footer]
      @slot_insert[:element] = nil
      @slot_insert[:before] = true
    else
      @slot_insert[:element] = @slot_insert[:id] == 0 ? nil : "page_slot_#{@slot_insert[:id]}"
    end
    
    true
  end
  
  def clear_slot
    page_slot.destroy if page_slot
  end
end