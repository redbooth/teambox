class Group
  belongs_to :user
  has_many :projects, :dependent => :nullify
  has_many :invitations, :dependent => :destroy
  has_and_belongs_to_many :users
end