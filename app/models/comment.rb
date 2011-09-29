class Comment < ActiveRecord::Base
  include Immortal
  
  extend ActiveSupport::Memoizable
  
  concerned_with :tasks, :finders, :conversions

  belongs_to :user
  belongs_to :project
  belongs_to :target, :polymorphic => true, :counter_cache => true
  belongs_to :assigned, :class_name => 'Person'
  belongs_to :previous_assigned, :class_name => 'Person'

  has_many :notifications, :dependent => :destroy
  attr_accessor :do_rollback

  def self.from_github(payload)

    payload['commits'].each_pair do |task_id, commits|

      if task = Task.find_by_id(task_id)

        body = GithubIntegration::Builder.comment_body_from_payload_commits(commits, payload)
        task.update_attribute(:status_name, :resolved) if GithubIntegration::Parser.task_close_in_any_commit?(commits)

        #first try to detect author by pushed param
        if payload.has_key? 'pusher'
          author = task.project.users.detect { |u| u.email == payload['pusher']['email'] || u.name == payload['pusher']['name']}
        end
        #if not found find user by name or email of last commit' author, if not found comment author will be user which is assigned to the task
        if author.nil?
          author_name_and_email = GithubIntegration::Parser.get_author_from_commits(commits)
          author = (task.project.users.detect { |u| u.email == author_name_and_email[:email] || u.name == author_name_and_email[:name] }) || task.assigned.user
        end

        task.comments.create_by_user author, {:body => body, :project_id => task.project_id}

      end
    end
  end

  def task_comment?
    self.target_type == "Task"
  end
  
  def user
    @user ||= user_id ? User.with_deleted.find_by_id(user_id) : nil
  end
  
  def assigned
    @assigned ||= assigned_id ? Person.with_deleted.find_by_id(assigned_id) : nil
  end
  
  def previous_assigned
    @previous_assigned ||= previous_assigned_id ? Person.with_deleted.find_by_id(previous_assigned_id) : nil
  end

  has_many :uploads
  accepts_nested_attributes_for :uploads, :allow_destroy => true,
    :reject_if => lambda { |upload| upload['asset'].blank? }
  
  has_many :google_docs
  accepts_nested_attributes_for :google_docs, :allow_destroy => true,
    :reject_if => lambda { |google_docs| google_docs['title'].blank? || google_docs['url'].blank? }
  
  attr_accessible :body, :status, :assigned, :hours, :human_hours, :billable,
    :upload_ids, :uploads_attributes, :due_on, :urgent, :google_docs_attributes, :private_ids, :is_private

  attr_accessor :is_importing, :private_ids, :is_private_set, :activity

  scope :by_user, lambda { |user| { :conditions => {:user_id => user} } }
  scope :latest, :order => 'id DESC'

  # TODO: investigate how we can enable this and not break nested attributes
  # validates_presence_of :target_id, :user_id, :project_id
  
  validate :check_duplicate, :if => lambda { |c| !@is_importing and !c.is_private_changed? and c.target_id? and not c.hours? }, :on => :create
  validates_presence_of :body, :unless => lambda { |c| c.is_private_set or c.task_comment? or c.uploads.to_a.any? or c.google_docs.any? }

  validates_presence_of :user

  # was before_create, but must happen before format_attributes
  before_save   :copy_ownership_from_target, :if => lambda { |c| c.new_record? and c.target_id? }
  before_validation   :copy_ownership_from_target, :on => :create, :if => lambda { |c| c.target }
  before_validation   :add_private_statechange, :on => :create
  
  before_destroy :check_task
  after_create  :trigger_target_callbacks
  after_destroy :cleanup_activities, :cleanup_conversation, :cleanup_task

  # must happen after copy_ownership_from_target
  formats_attributes :body

  def hours?
    hours and hours > 0
  end

  scope :with_hours, :conditions => 'hours > 0'

  alias_attribute :human_hours, :hours

  # Instead of using the float 'hours' field in a form, we use 'human_hours'
  # and we can take:
  # 7 (hours)
  # 7.5 (hours with decimals)
  # 7h (hours)
  # 30m (minutes => fractions of hours)
  # 2h 30m (hours and minutes => hours with decimals)
  # 2:30 (hours and minutes => hours with decimals)
  def human_hours=(duration)
    self.hours = if duration.blank?
      nil
    elsif duration =~ /(\d+)h[ ]*(\d+)m/i
      # 2h 15m
      $1.to_f + $2.to_f / 60
    elsif duration =~ /(\d+):(\d+)/
      # 2:15
      $1.to_f + $2.to_f / 60.0
    elsif duration =~ /(\d+)m/i
      # 20m
      $1.to_f / 60.0
    elsif duration =~ /(\d+)h/i
      # 3h
      $1.to_f
    else
      # old-style numeric format
      duration.to_f
    end
  end

  def duplicate_of?(another)
    [:body, :assigned_id, :status, :hours].all? { |prop|
      self.send(prop) == another.send(prop)
    }
  end

  def thread_id
    "#{target_type}_#{target_id}"
  end
  
  def references
    refs = { :users => [user_id], :projects => [project_id], :uploads => upload_ids, :google_docs => google_doc_ids }
    refs.merge!({ target_type.tableize.to_sym => [target_id] })
    refs[:people] = []
    refs[:people] << assigned_id if assigned_id
    refs[:people] << previous_assigned_id if previous_assigned_id
    refs
  end
  
  protected

  # don't allow two identical updates in a row
  #
  # FIXME: doesn't work with "simple" conversations because
  # they hijack `target` in a before_save callback
  def check_duplicate
    last_comment = target.comments.by_user(self.user_id).latest.first

    if last_comment and last_comment.duplicate_of? self
      last_uploads = last_comment.uploads.map {|x| x.asset_file_name + '_' + x.asset_file_size.to_s }.sort
      current_uploads = self.uploads.map {|x| x.asset_file_name + '_' + x.asset_file_size.to_s }.sort
      if current_uploads == last_uploads
        errors.add :body, :duplicate
      end
    end
  end

  def copy_ownership_from_target # before_create
    self.user_id ||= target.user_id
    self.project_id ||= target.project_id
    # Private field inherits from target UNLESS it is set and its being changed by the owner
    can_change_private = self.user_id == target.user_id
    if target.respond_to?(:is_private)
      self[:is_private] = target.is_private unless can_change_private && @is_private_set
    end
    true
  end
  
  def is_private_change?
    target.is_private != is_private
  end
  
  def span_for_is_private_html(is_private)
    if is_private
      "<span class=\"is_private_state\">PRIVATE</span>"
    else
      "<span class=\"is_public_state\">PRIVATE</span>"
    end
  end
  
  def task_is_private_html
    [].tap do |out|
      if is_private_change?
        out << span_for_is_private_html(target.is_private)
        out << "<span class=\"arr is_private_arr\">&rarr;</span>"
        out << span_for_is_private_html(is_private)
      end
    end.join('')
  end
  
  def add_private_statechange
    if is_private_set && is_private_change?
      self.body = "#{task_is_private_html}\n\n#{body}"
    end
    true
  end
  
  def is_private=(value)
    self[:is_private] = value
    @is_private_set = true
  end

  def trigger_target_callbacks # after_create
    @activity = project.log_activity(self, 'create') if project_id?
    return if target.nil?

    self.add_target_watchers!
    self.touch_target_without_callback!
    true
  end

  def touch_target_without_callback!
    if target.respond_to?(:updated_at)
      target.updated_at = self.created_at
    end

    target.save(:validate => false)
  end

  def target_belongs_to_commenter?
    self.user_id == target.user_id
  end

  def add_mentions_to_watchers!
    new_watchers = defined?(@mentioned) ? @mentioned.to_a : []
    new_watchers << self.user if self.user
    target.add_watchers new_watchers
  end

  def add_target_watchers!
    if target.respond_to?(:add_watchers)
      can_mention_watchers = true
      
      # Allow the owner to change the privacy status
      if target.respond_to?(:is_private)
        target.is_private = self.is_private if target_belongs_to_commenter? && @is_private_set
        if target.is_private && target_belongs_to_commenter? && @private_ids && @is_private_set
          target.set_private_watchers(@private_ids)
        elsif target.is_private
          target.add_watchers([target.user])
        end

        if !target.is_private
          add_mentions_to_watchers!
        end
      end
    end
  end

  def cleanup_activities # after_destroy
    Activity.destroy_all :target_type => self.class.name, :target_id => self.id
  end
  
  def cleanup_conversation
    if self.target.class == Conversation
      @conversation = self.target
      @conversation.destroy if @conversation.simple and @conversation.comments.count == 0
    end
  end
  
  def check_task
    @last_comment_in_task = if @do_rollback && target_type == 'Task' && target
      list = target.comments.order('id DESC').limit(2)
      list.first.try(:id) == id && list.length > 1
    else
      false
    end
    true
  end
  
  def cleanup_task
    if @last_comment_in_task
      self.target.assigned_id = previous_assigned_id
      self.target.due_on = previous_due_on
      self.target.urgent = previous_urgent
      self.target.status = previous_status || Task::STATUSES[:open]
      self.target.save!
    end
    true
  end
end
