class AppLink < ActiveRecord::Base

  belongs_to :user
  validates_uniqueness_of :app_user_id, :scope => :provider
  validates_uniqueness_of :user_id, :scope => :provider, :allow_nil => true

end