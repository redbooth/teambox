class Hour < ActiveRecord::Base
  belong_to :project
  belongs_to :comment
  belongs_to :user
end  