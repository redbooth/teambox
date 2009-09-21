module CalendarsHelper

  def list_hour_users(users)
    render :partial => 'hours/user_filter', :locals => { :users => users.uniq }
  end

  def observe_user_filter
    update_page_tag do |page|
      page['user_filter'].observe('change') { |page| page.apply_user_filter }
    end
  end
  
  def apply_user_filter
    page << "if (this.selectedIndex == 0) {"
      page.select('.hour').invoke('show')
    page.els
      page['total_sum'].hide
      page.select('.hour').invoke('hide')
      page << "$$('.hour_' + this.getValue()).invoke('show');"
    page.en
  end

  def day_hours(comments)
    @users_displayed ||= []
    day_hours = {}
    comments.group_by(&:day).each do |day, comments|
      comments.each { |c| @users_displayed << c.user }
      day_hours[day] = comments
    end
    day_hours
  end

  def user_class_name(user,text = 'hours')
    @current_class_name ||= 0
    @class_names ||= {}
    @class_names[user.to_s] ||= (@current_class_name += 1)
    "#{text}_#{@class_names[user.to_s]} hour_#{user} hour"
  end

  def week_hours
    
  end

  def build_small_calendar(comments,year,month)
    build_calendar(comments,year,month,true)
  end
  
  def build_calendar(comments,year,month,small=false)
    first = Date.civil(year,month, 1)
    last = Date.civil(year,month, -1)
    first_weekday = first_day_of_week(0)
    last_weekday = last_day_of_week(0)

    cal = ''
    cal << print_previous_month_days(first_weekday,first,small)
    
    tally = {}
    week_tally = {}
    total_tally = {}
    total_sum = 0
    
    first.upto(last) do |cur|
      current_day = add_zero_for_first_week(cur)

      day_hours = day_hours(comments)
      if day_hours.has_key?(current_day)
        cell_text  ||= "#{cur.mday}"
        day_hours[current_day].each do |c|
          tally[c.user.login] ||= 0; tally[c.user.login] += c.hours
          week_tally[c.user.login] ||= 0; week_tally[c.user.login] += c.hours
          total_tally[c.user.login] ||= 0; total_tally[c.user.login] += c.hours;
          total_sum += c.hours
          cell_text << content_tag(:p,"#{c.user.login} #{c.hours} hrs", :class => user_class_name(c.user.login,'hours'))
        end
      else
        cell_text  ||= cur.mday
      end
      cell_attrs = {}
      cell_attrs[:class] = "day this_month #{'today' if (cur == Time.current.to_date)} "
      cell_attrs[:id] = "day_#{cur.mday}"

      #if markable?(calendar,marked,year,month,cell_text)
      #  cell_attrs[:class] += 'markable'
      #  cell_attrs[:onclick] = "Mark.mark_calendar_block('#{form_authenticity_token}','#{calendar.permalink}',#{cell_text},#{month},#{year});"
      #end

      cal << assign_day(cell_attrs,cell_text,last_weekday,cur,week_tally,last)
      if cur.wday == last_weekday
        week_tally = {}
      end
    end
    cal << print_next_month_days(first_weekday,last_weekday,week_tally,last,total_tally,total_sum)
  end

  private

  def assign_day(cell_attrs,cell_text,last_weekday,cur,week_tally,last)
    cell_attrs = cell_attrs.map {|k, v| %(#{k}="#{v}") }.join(" ")
    cal = "<td #{cell_attrs}>#{cell_text}</td>"
    if cur.wday == last_weekday
      cal << "<td class='total'>"
      week_tally.each { |i,w|
        cal << content_tag(:p,"#{i} #{w}", :class => user_class_name(i,'week_total') ) }
      cal << "</td></tr><tr>"
    end  
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
    cal << "<th>Weekly Total</th></tr><tr>"
  
    beginning_of_week(first, first_weekday).upto(first - 1) do |d|
      cal << %(<td class="previous_month)
      cal << " weekendDay" if weekend?(d)
      cal << %(">#{d.day}</td>)
    end unless first.wday == first_weekday   
    return cal 
  end

  def print_next_month_days(first_weekday,last_weekday,week_tally,last,total_tally,total_sum)
    cal = ''
    (last + 1).upto(beginning_of_week(last + 7, first_weekday) - 1)  do |d|
      cal << %(<td class="next_month)
      cal << " weekendDay" if weekend?(d)
      cal << %(">#{d.day}</td>)        
    end unless last.wday == last_weekday
    cal << "<td class='total'>"
    week_tally.each { |i,w| 
      cal << content_tag(:p,"#{i} #{w}", :class => user_class_name(i,'week_total') ) }
    cal << "</td></tr><tr>"
    cal << "<tr><td class='blank' colspan='7'></td><td class='max_total total'>"
    total_tally.each { |i,w|
      cal << content_tag(:p,"#{i} #{w}", :class => user_class_name(i,'month_total') ) }
    cal << "<p id='total_sum' class='hour'>Total: #{total_sum}"
    cal << "</td></tr>"
    cal << "</table>"
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

  def link_to_last_month(project,year,month)
    if month == 1
      month = 12
      year -= 1
    else
      month -= 1
    end  
    link_to '&larr;', project_hours_by_month_url(project,year,month)
  end

  def link_to_next_month(project,year,month)
    if month == 12
      month = 1
      year += 1
    else
      month += 1
    end    
    link_to '&rarr;', project_hours_by_month_url(project,year,month)
  end

  def calendar_nav(project,year,month)
    render :partial => 'hours/calendar_navigation',
      :locals => { 
        :project => project,
        :year => year,
        :month => month }
  end
  
end  