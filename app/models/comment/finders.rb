class Comment

  def self.find_by_year(year=nil)
    year ||= Time.new.year
    find(:all, :conditions => ["YEAR(created_at) = ?", year], :order => 'created_at DESC')
  end
  
  def self.find_by_year_count(year=nil)
    year ||= Time.new.year
    count(:all, :conditions => ["YEAR(created_at) = ?", year])
  end

  def self.find_by_month(month_number=nil,year_number=nil)
    month_number ||= Time.new.month
    with_scope(:find => { :conditions => ["MONTH(created_at) = ?", month_number], :order => 'created_at DESC'}) do
      find_by_year(year_number)
    end
  end

  def self.find_by_week(week_number=nil)
    week_number ||= (Time.new.beginning_of_week - 7.days).strftime("%U").to_i + 1

    with_scope(:find => { :conditions => ["WEEK(created_at) = ?", week_number], :order => 'created_at DESC'}) do
      find_by_year
    end
  end
  
  def self.find_today
    with_scope(:find => { :conditions => ["DAY(created_at) = ?", Time.current.day], :order => 'created_at ASC'}) do
      find_by_year
      find_by_month
    end
  end
  
end