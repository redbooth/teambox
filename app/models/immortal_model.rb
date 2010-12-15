class ImmortalModel < ActiveRecord::Base
  include Immortal

  attr_accessor :before, :after, :before_update, :after_update
  
  before_destroy :set_before
  after_destroy  :set_after
  before_update    :set_before_update
  after_update     :set_after_update
  
  def set_before
    @before = true
  end
  
  def set_after
    @after = true
  end

  def set_after_update
    @after_update = true
  end

  def set_before_update
    @before_update = true
  end

end
