class Watcher < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :watchable, :polymorphic => true

  before_save :copy_project_from_watchable

  private

    def copy_project_from_watchable
      self.project = watchable.project unless project || watchable.project.nil?
    end
end
