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

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.file :id => id do
      xml.tag! 'title', title
      xml.tag! 'document_type', document_type
      xml.tag! 'url', url
      xml.tag! 'edit-url', edit_url
      xml.tag! 'acl-url', acl_url
      xml.tag! 'created-at', created_at.to_s(:db)
      xml.tag! 'updated-at', updated_at.to_s(:db)
      xml.tag! 'comment_id', comment_id
      xml.tag! 'user-id', user_id
      xml.tag! 'project-id', project_id
    end
  end
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :title => title,
      :document_type => document_type,
      :url => url,
      :edit_url => edit_url,
      :acl_url => acl_url,
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:api_time),
      :user_id => user_id,
      :comment_id => comment_id,
      :project_id => project_id
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    base
  end


  
  private
    def copy_ownership_from_comment
      if comment_id
        self.user_id = comment.user_id
        self.project_id = comment.project_id
      end
    end
end
