class Comment
    
  def previously_closed?
    [:rejected, :resolved].include? previous_status_name
  end
  
  def transition?
    status_transition? || assigned_transition? || due_on_change? || urgent_change?
  end

  def initial_status?
    status? and not previous_status?
  end

  def due_on_transition?
    due_on != previous_due_on and !previous_due_on.nil?
  end

  def due_on_change?
    due_on != previous_due_on
  end

  def urgent_change?
    urgent != previous_urgent
  end

  def urgent_transition?
    urgent? != previous_urgent? and previous_urgent?
  end

  def assigned_transition?
    assigned_id != previous_assigned_id
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

  def due_on?
    !due_on.nil?
  end

  def previous_due_on?
    !previous_due_on.nil?
  end

  def status_open?
    Task::STATUSES[:open] == status
  end

  def previous_status_open?
    Task::STATUSES[:open] == previous_status
  end
  
  def status_name
    Task::STATUS_NAMES[status || 0]
  end
  
  def previous_status_name
    Task::STATUS_NAMES[previous_status]
  end
  
end
