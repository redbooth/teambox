module CalendarsHelper

  def list_hour_filters(project)
    render 'hours/filter'
  end
  
  def list_hour_reports
    render 'hours/report_list'
  end
  
  def day_hours(comments)
    @users_displayed ||= comments.map(&:user)
    comments.group_by { |c| c.created_at.mday }
  end

  def user_class_name(user,text = 'hours')
    @current_class_name ||= 0
    @class_names ||= {}
    @class_names[user.to_s] ||= (@current_class_name += 1)
    "#{text}_#{@class_names[user.to_s]} hour_#{user} hour"
  end

  def build_small_calendar(comments,year,month)
    build_calendar(comments,year,month,true)
  end

  def start_of_calendar(year, month)
    first = Date.civil(year,month, 1)
    weekdays = calendar_weekdays
    first_weekday, last_weekday = weekdays[0], weekdays[1]
    beginning_of_week(first, first_weekday)
  end

  def end_of_calendar(year, month)
    dm = month+1 > 12 ? 1 : month+1
    dy = month+1 > 12 ? year+1 : year
    first = Date.civil(dy,dm, 1)
    weekdays = calendar_weekdays
    first_weekday, last_weekday = weekdays[0], weekdays[1]
    beginning_of_week(first, first_weekday) + 7
  end

  def calendar_weekdays
    n = (current_user.first_day_of_week == 'monday' ? 1 : 0)
    [first_day_of_week(n), last_day_of_week(n)]
  end

  def build_calendar(year,month,small=false)
    first = Date.civil(year,month, 1)
    last = Date.civil(year,month, -1)
    weekdays = calendar_weekdays
    first_weekday, last_weekday = weekdays[0], weekdays[1]

    cal = ''
    cal << print_previous_month_days(first_weekday,first,small)

    week_tally = {}
    total_tally = {}
    total_sum = 0
    week_count = 0
 
    first.upto(last) do |cur|
      current_day = add_zero_for_first_week(cur)

      cell_text = "<div class=\"cd\">#{cur.mday}</div>"
      cell_attrs = {}
      cell_attrs[:class] = "day this_month cal_wd#{cur.wday} #{'today' if (cur == Time.current.to_date)} "
      cell_attrs[:id] = "day_#{cur.month}_#{cur.mday}"

      #if markable?(calendar,marked,year,month,cell_text)
      # cell_attrs[:class] += 'markable'
      # cell_attrs[:onclick] = "Mark.mark_calendar_block('#{form_authenticity_token}','#{calendar.permalink}',#{cell_text},#{month},#{year});"
      #end
      cal << assign_day(cell_attrs,cell_text,last_weekday,cur,week_tally,week_count,last)
      if cur.wday == last_weekday
        week_tally = {}
        week_count += 1
      end
    end
    cal << print_next_month_days(first_weekday,last_weekday,week_tally,week_count,last,total_tally,total_sum)
    cal.html_safe
  end

  def build_weektable(year, month)
    first = start_of_calendar(year, month)
    last = end_of_calendar(year, month)
    weeks = ((last - first) / 7).ceil
  
    wk = "<table class=\"weektable#{weeks} #{first} #{last}\"><tr>"
  
    wk << (0...weeks).map do |week|
      "<th>#{t('hours.week_num', :num => week+1)}</th>"
    end.join('')
    wk << "<th>#{t('hours.week_total')}</th>"
  
    wk << '</tr><tr>'
    wk << (0...weeks).map do |week|
      "<td id=\"week_#{week}\"></td>"
    end.join('')
    wk << "<td id=\"hour_total\" class=\"max_total total\">"
    wk << '</tr><tr>'
    wk << "<td colspan=\"#{weeks}\" class=\"blank\"></td><td class=\"max_total total\">"
    wk << "<p id='total_sum' class='hour'>0#{t('hours.entry_hours')}</p>"

    wk << '</td></tr><tr>'
    wk << '</tr></table>' 
    wk.html_safe
  end

  private

  def assign_day(cell_attrs,cell_text,last_weekday,cur,week_tally,week_count,last)
    cell_attrs = cell_attrs.map {|k, v| %(#{k}="#{v}") }.join(" ")
    cal = "<td #{cell_attrs}>#{cell_text}</td>"
    if cur.wday == last_weekday
      cal << "</tr><tr>"
    end
    cal.html_safe
  end

  def day_names(first_weekday)
   c = -1
   dn = I18n.translate('date.day_names').map {|d| c += 1; [d, c]}
   first_weekday.times do
     dn.push(dn.shift)
   end
   dn
  end

  def add_zero_for_first_week(cur)
   if cur.mday.to_s.length == 1
     "0#{cur.mday.to_s}"
   else
     cur.mday.to_s
   end    
  end

  def print_previous_month_days(first_weekday,first,abbreviate=false)
    cal = %(<table><tr>)
    cal << day_names(first_weekday).collect do |d| 
      val = if abbreviate
        truncate(d[0], :length => 1, :omission => '')
      else
        d[0]
      end
      "<th class=\"cal_wd#{d[1]}\">#{val}</th>"
    end.join('')
    #cal << "<th>Weekly Total</th>"
    cal << "</tr><tr>"

    beginning_of_week(first, first_weekday).upto(first - 1) do |d|
      cal << %(<td id="day_#{d.month}_#{d.mday}" class="previous_month cal_wd#{d.wday})
      cal << " weekendDay" if weekend?(d)
      cal << %("><div class=\"cd\">#{d.day}</div></td>)
    end unless first.wday == first_weekday
    cal.html_safe
  end

  def print_next_month_days(first_weekday,last_weekday,week_tally,week_count,last,total_tally,total_sum)
    cal = ''
    (last + 1).upto(beginning_of_week(last + 7, first_weekday) - 1)  do |d|
      cal << %(<td class="next_month cal_wd#{d.wday})
      cal << " weekendDay" if weekend?(d)
      cal << %("><div class=\"cd\">#{d.day}</div></td>)
    end unless last.wday == last_weekday
    cal << "</tr>"
    cal << "</table>"
    cal.html_safe
  end

  def first_day_of_week(day)
    day
  end
 
  def last_day_of_week(day)
    (day > 0) ? (day - 1) : 6
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
    url = project ? project_hours_by_month_url(project,year,month) : hours_by_month_url(year,month)
    link_to "&larr; #{I18n.t('common.prev')}".html_safe, url
  end

  def link_to_next_month(project,year,month)
    if month == 12
      month = 1
      year += 1
    else
      month += 1
    end
    url = project ? project_hours_by_month_url(project,year,month) : hours_by_month_url(year,month)
    link_to "#{I18n.t('common.next')} &rarr;".html_safe, url
  end

  def hours_js(year, month, comments)
    taskmap = {}
    projectmap = {}
    organizationmap = {}

    args = @comments.map do |comment|
      date = comment.created_at.in_time_zone(current_user.time_zone)
      task = (comment.target && comment.target.class == Task) ? comment.target : nil
      organizationmap[comment.project.organization_id] ||= h(comment.project.organization.name)
      projectmap[comment.project_id] ||= comment.project.name
      taskmap[task.id] ||= h(task.name) unless task.nil?
      { :id => comment.id,
        :date => [date.year, date.month-1, date.day],
        :project_id => comment.project_id,
        :organization_id => comment.project.organization_id,
        :user_id => comment.user_id,
        :task_id => task ? task.id : 0,
        :hours => comment.hours.to_f
      }.to_json
    end
 
    usermap = {}
    usernamemap = {}

    if @current_project
      @current_project.users.each {|u| usermap[u.id] = u.login; usernamemap[u.id] = h(u.name)}
    else
      @current_user.users_with_shared_projects.each {|u| usermap[u.id] = u.login; usernamemap[u.id] = h(u.name)}
    end
 
    start_date = start_of_calendar(year, month)
    start = "new Date(#{start_date.year}, #{start_date.month-1}, #{start_date.day})"
    
    javascript_tag <<-EOS
      HOURS_DATA = {
        start: #{start},
        hours: [#{args.join(',')}],
        userMap: #{usermap.to_json},
        userNameMap: #{usernamemap.to_json},
        taskMap: #{taskmap.to_json},
        projectMap: #{projectmap.to_json},
        organizationMap: #{organizationmap.to_json}
      }
    EOS
  end

  def filter_hours_assigned_dropdown(target_id, project=nil)
    options = [[t('hours.filter_assigned.anybody'),     0],
               [t('hours.filter_assigned.my_tasks'),    current_user.id]]
    user_list = project ? project.users.sort_by(&:name) : Person.users_from_projects(current_user.projects)
    if user_list
      options += [['--------', 'divider']]
      options += user_list.
                 reject { |u| u == current_user }.
                 collect { |u| [u.name, u.id] }
    end
    select(:hours_user_filter, :assigned, options, :disabled => 'divider', :id => target_id)
  end

  def filter_project_dropdown(target_id)
    options = [[t('hours.filter_project.all'),     0]]
    options += [['--------', 'divider']]
    options += current_user.projects.sort_by(&:name).collect { |p| [p.name, p.id] }
    select(:hours_project_filter, :assigned, options, :disabled => 'divider', :id => target_id)
  end

  def filter_organization_dropdown(target_id)
    options = [[t('hours.filter_organization.all'),     0]]
    options += [['--------', 'divider']]
    options += current_user.organizations.sort_by(&:name).collect { |p| [p.name, p.id] }
    select(:hours_organization_filter, :assigned, options, :disabled => 'divider', :id => target_id)
  end

  def calendar_nav(project,year,month)
   render 'hours/calendar_navigation',
     :project => project,
     :year => year,
     :month => month
  end
   
end  