class Card < ActiveRecord::Base

  belongs_to :user
  has_many :phone_numbers
  has_many :addresses
  has_many :email_addresses
  has_many :websites
  has_many :ims
  has_many :social_networks

  with_options :allow_destroy => true, :reject_if => proc { |a| a['name'].blank? } do |card|
    card.accepts_nested_attributes_for :phone_numbers
    card.accepts_nested_attributes_for :email_addresses
    card.accepts_nested_attributes_for :websites
    card.accepts_nested_attributes_for :ims
    card.accepts_nested_attributes_for :social_networks
  end
  
  accepts_nested_attributes_for :addresses, :allow_destroy => true, :reject_if => proc { |address|
    address['street'].blank? and address['city'].blank?
  }
  
end
