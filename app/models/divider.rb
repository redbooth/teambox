class Divider < RoleRecord
  belongs_to :page
  belongs_to :project
  acts_as_paranoid

  attr_accessor :deleted
  attr_accessible :body, :deleted, :name
end