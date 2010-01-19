class Comment
    
  def previously_closed?
    [Task::STATUSES[:rejected],Task::STATUSES[:resolved]].include?(previous_status)
  end
  
  def transition?
    status_transition? || assigned_transition?
  end
    
  def assigned_transition?
    assigned != previous_assigned
  end
  
  def status_transition?
    status != previous_status
  end

  def assigned?
    !assigned.nil?    
  end

  def previous_assigned?
    !previous_assigned.nil?
  end

  def status_open?
    Task::STATUSES[:open] == status
  end

  def previous_status_open?
    Task::STATUSES[:open] == previous_status
  end
  
  def status_name
    key = nil
    Task::STATUSES.each{|k,v| key = k.to_s if status.to_i == v.to_i } 
    key
  end

  def previous_status_name
    key = nil
    Task::STATUSES.each{|k,v| key = k.to_s if previous_status.to_i == v.to_i } 
    key
  end
  
end