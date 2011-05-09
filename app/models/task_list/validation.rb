class TaskList
  validates_presence_of :user
  validates_presence_of :name, :message => I18n.t('task_lists.errors.name.cant_be_blank')
  validates_length_of   :name, :maximum => 255, :message => I18n.t('task_lists.errors.name.too_long')
end