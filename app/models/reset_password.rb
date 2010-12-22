require 'digest/sha1'

class ResetPassword < ActiveRecord::Base
  belongs_to :user
  attr_accessor :email
  validates_presence_of :email, :on => :create
  validates_format_of :email, :on => :create, :unless => Proc.new{|p|p.email.blank?}, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'is not a valid email address'
  validates_each :user, :unless => Proc.new{|p|p.errors[:email].present?} do |record, attr, value|
    record.errors.add attr, "doesn\'t exist in the system." if record.user.nil? or record.user.deleted?
  end
  
  before_create :create_code

  protected
  
  def create_code
    self.reset_code = ActiveSupport::SecureRandom.hex(20)
    self.expiration_date = 2.weeks.from_now
  end
end