class Notification < ActiveRecord::Base
  belongs_to :person
  belongs_to :comment
  belongs_to :target, :polymorphic => true
end