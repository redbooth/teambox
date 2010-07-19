require_dependency 'role_record'

class Conversation < RoleRecord
  has_many :uploads
  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy

  serialize :watchers_ids

  attr_accessible :name, :simple
  attr_accessor :body

  validates_presence_of :name, :message => :no_title, :unless => :simple?
  validates_presence_of :body, :message => :no_body_generic, :on => :create

  named_scope :only_simple, :conditions => { :simple => true }
  named_scope :not_simple, :conditions => { :simple => false }

  def after_create
    project.log_activity(self,'create')
    add_watcher(self.user) 

    if @body
      comment = self.comments.new do |comment|
        comment.project_id = self.project_id
        comment.user_id = self.user_id
        comment.body = self.body
      end

      comment.save!
    end
    if simple
      update_attribute :name, body.split("\n").first.chomp
    end
  end

  def after_destroy
    Activity.destroy_all  :target_id => self.id, :target_type => self.class.to_s
  end

  def owner?(u)
    user == u
  end

  def notify_new_comment(comment)
    self.watchers.each do |user|
      if user != comment.user and user.notify_conversations
        Emailer.send_with_language(:notify_conversation, user.language, user, self.project, self) # deliver_notify_conversation
      end
    end
    self.sync_watchers
  end
  
  def to_s
    name
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.conversation :id => id do
      xml.tag! 'project-id',      project_id
      xml.tag! 'user-id',         user_id
      xml.tag! 'name',            name
      xml.tag! 'created-at',      created_at.to_s(:db)
      xml.tag! 'updated-at',      updated_at.to_s(:db)
      xml.tag! 'watchers',        watchers_ids.join(',')
      if Array(options[:include]).include? :comments
        comments.to_xml(options.merge({ :skip_instruct => true }))
      end
    end
  end
end