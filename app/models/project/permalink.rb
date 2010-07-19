require_dependency 'grab_name'

class Project
  
  include GrabName
  has_permalink :name
  
  def self.grab_name_by_permalink(permalink)
    p = self.find_by_permalink(permalink,:select => 'name')
    p.try(:name) || ''
  end
  
end