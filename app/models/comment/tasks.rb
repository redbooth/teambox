class Comment
    
  def previously_closed?
    [:rejected, :resolved].include? previous_status_name
  end
  
  def transition?
    status_transition? || assigned_transition?
  end
    
  def assigned_transition?
    assigned != previous_assigned
  end
  
  def status_transition?
    previous_status && status != previous_status
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
    Task::STATUS_NAMES[status]
  end
  
  def previous_status_name
    Task::STATUS_NAMES[previous_status]
  end
  
end