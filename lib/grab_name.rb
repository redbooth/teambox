module GrabName
  protected
    def self.grab_name(id)
      e = self.find(id,:select => 'name')
      e = e.nil? ? '' : e.name
    end
end  