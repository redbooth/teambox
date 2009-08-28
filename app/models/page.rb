class Page < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  
  has_many :sections, :class_name => "PageSection"
  has_many :dividers
  
  attr_accessible :name, :body
  
  def build_divider()
    self.page_dividers.new do |divider|
    end
  end
  
  def build_section(user,project,target)
    section = new_section(user,project,target)
    section.save
    section
  end
  
  def new_section(user,project,target)
    self.sections.new do |section|
      section.user_id = user.id
      section.project_id = project.id
      section.target = target
    end
  end
end