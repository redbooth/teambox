module CalendarsHelper

  def build_small_calendar(calendar,year,month)
    build_calendar(calendar,year,month,true)
  end
  
  def build_calendar(year,month,small=false)
    first = Date.civil(year,month, 1)
    last = Date.civil(year,month, -1)
    first_weekday = first_day_of_week(0)
    last_weekday = last_day_of_week(0)

    cal = ''
    cal << print_previous_month_days(first_weekday,first,small)

    first.upto(last) do |cur|

      current_day = add_zero_for_first_week(cur)

      #marked = marks.has_key?(current_day) && marks[current_day].accomplished ? 'marked' : nil
      #mark = marks[current_day] if marks.has_key?(current_day)
    
      cell_text  ||= cur.mday
      cell_attrs = {}
      cell_attrs[:class] = "day this_month #{'today' if (cur == Time.current.to_date)} "
      cell_attrs[:id] = "day_#{cur.mday}"
    
      #if markable?(calendar,marked,year,month,cell_text)
      #  cell_attrs[:class] += 'markable'
      #  cell_attrs[:onclick] = "Mark.mark_calendar_block('#{form_authenticity_token}','#{calendar.permalink}',#{cell_text},#{month},#{year});"
      #end
    
      cal << assign_day(cell_attrs,cell_text,last_weekday,cur)

    end    
    cal << print_next_month_days(first_weekday,last_weekday,last)
  end

  private

  def assign_day(cell_attrs,cell_text,last_weekday,cur)
    cell_attrs = cell_attrs.map {|k, v| %(#{k}="#{v}") }.join(" ")
    cal = "<td #{cell_attrs}>#{cell_text}</td>"
    cal << "</tr><tr>" if cur.wday == last_weekday
    return cal
  end

  def day_names(first_weekday)
    dn = I18n.translate('date.day_names')    
    first_weekday.times do
      dn.push(dn.shift)
    end
    return dn
  end

  def add_zero_for_first_week(cur)
    if cur.mday.to_s.length == 1
      current_day = "0#{cur.mday.to_s}"
    else
      current_day =  cur.mday.to_s
    end    
  end

  def print_previous_month_days(first_weekday,first,abbreviate=false)
    cal = %(<table><tr>)
    cal << day_names(first_weekday).collect do |d| 
      if abbreviate
        "<th>#{truncate(d, :length => 1, :omission => '')}</th>" 
      else  
        "<th>#{d}</th>"         
      end
    end.join('')
    cal << "</tr><tr>"
  
    beginning_of_week(first, first_weekday).upto(first - 1) do |d|
      cal << %(<td class="previous_month)
      cal << " weekendDay" if weekend?(d)
      cal << %(">#{d.day}</td>)
    end unless first.wday == first_weekday   
    return cal 
  end

  def print_next_month_days(first_weekday,last_weekday,last)
    cal = ''
    (last + 1).upto(beginning_of_week(last + 7, first_weekday) - 1)  do |d|
      cal << %(<td class="next_month)
      cal << " weekendDay" if weekend?(d)
      cal << %(">#{d.day}</td>)        
    end unless last.wday == last_weekday
    cal << "</tr></table>"    
  end

  def first_day_of_week(day)
    day
  end

  def last_day_of_week(day)
    if day > 0
      day - 1
    else
      6
    end
  end

  def days_between(first, second)
    if first > second
      second + (7 - first)
    else
      second - first
    end
  end

  def beginning_of_week(date, start = 1)
    days_to_beg = days_between(start, date.wday)
    date - days_to_beg
  end

  def weekend?(date)
    [0, 6].include?(date.wday)
  end

  def sort_by_days(marks)
    array_of_marks = marks.group_by{ |m| m.marked_on.strftime('%d') }
    marks = {}
    array_of_marks.each do |mark|
      marks[mark[0]] = mark[1][0]
    end    
    marks
  end

  def link_to_last_month(year,month)
    if month == 1
      month = 12
      year -= 1
    else
      month -= 1
    end  
    link_to '&larr;', ''
  end

  def link_to_next_month(year,month)
    if month == 12
      month = 1
      year += 1
    else
      month += 1
    end    
    link_to '&rarr;', ''
  end

end  