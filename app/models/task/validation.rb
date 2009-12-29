class Task
  validates_presence_of :name, :message => I18n.t('tasks.errors.name.cant_be_blank')
  validates_length_of   :name, :maximum => 255, :message => I18n.t('tasks.errors.name.too_long')
    
  validates_each :assigned do |record, attr, value|
    if value and not record.project.people.include?(value)
      record.errors.add attr, "doesn't belong to the project"
    end
  end
end