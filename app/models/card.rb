class Card < ActiveRecord::Base
  belongs_to :user

  has_many :phone_numbers
  accepts_nested_attributes_for :phone_numbers, :allow_destroy => true, :reject_if => proc { |a| a['name'].blank? }
  has_many :addresses
  accepts_nested_attributes_for :addresses, :allow_destroy => true
  has_many :email_addresses
  accepts_nested_attributes_for :email_addresses, :allow_destroy => true, :reject_if => proc { |a| a['name'].blank? }
  has_many :websites
  accepts_nested_attributes_for :websites, :allow_destroy => true, :reject_if => proc { |a| a['name'].blank? }
  has_many :ims
  accepts_nested_attributes_for :ims, :allow_destroy => true, :reject_if => proc { |a| a['name'].blank? }
  has_many :social_networks
  accepts_nested_attributes_for :social_networks, :allow_destroy => true, :reject_if => proc { |a| a['name'].blank? }
  
end  