class Task
  validates_length_of :name, :within => 1..255
    
  validates_each :assigned do |record, attr, value|
    if value and not record.project.people.include?(value)
      record.errors.add attr, "doesn't belong to the project"
    end
  end
end