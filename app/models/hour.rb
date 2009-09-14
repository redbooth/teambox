class Hour < ActiveRecord::Base
  belongs_to :project
  belongs_to :comment
  belongs_to :user
end  