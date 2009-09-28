class Note < ActiveRecord::Base
  belongs_to :page
  belongs_to :project
  
  formats_attributes :body
  
  has_many :uploads
  
  attr_accessor :deleted
  attr_accessible :body, :deleted, :name
  
  def html_id
    if self.new_record?
      if @html_id.nil?
        @html_id = rand(999999999)
      end
      
      @html_id
    else
      self.id
    end
  end
end