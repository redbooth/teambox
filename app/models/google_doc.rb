class GoogleDoc < RoleRecord
  include Immortal
  belongs_to :user
  belongs_to :project
  belongs_to :comment, :touch => true
  
  validates_presence_of :title
  validates_presence_of :url
  validates_presence_of :document_type
  
  attr_accessible :title, :document_type, :url, :edit_url, :acl_url
  
  before_create :copy_ownership_from_comment
  
  private
    def copy_ownership_from_comment
      if comment_id
        self.user_id = comment.user_id
        self.project_id = comment.project_id
      end
    end
end
