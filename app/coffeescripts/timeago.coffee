# Formats the time.timeago of comments to display a relative date.
# Relies on some translations defined in environment.erb

window.format_posted_date = ->
  $$('time.timeago').each (c) ->
    current_date = new Date
    posted_date = new Date(parseInt(c.readAttribute('data-msec')))

    posted_date_beginning_of_day = new Date(posted_date)
    posted_date_beginning_of_day.setHours(0)
    posted_date_beginning_of_day.setMinutes(0)
    posted_date_beginning_of_day.setSeconds(0)

    current_date_beginning_of_day = new Date(current_date)
    current_date_beginning_of_day.setHours(0)
    current_date_beginning_of_day.setMinutes(0)
    current_date_beginning_of_day.setSeconds(0)

    minutes = Math.floor((current_date-posted_date) / (1000 * 60))
    days = Math.floor((current_date_beginning_of_day-posted_date_beginning_of_day) / (1000 * 60 * 60 * 24))
    today = current_date.getDay() == posted_date.getDay() && days < 2

    if minutes < 0
      return
    else if minutes < 60
      c.update minutesAgoInWords(minutes)
    else if today
      c.update posted_date.strftime(time_format_short)
    else if days == 1
      c.update date_yesterday + ' ' + posted_date.strftime(time_format_short)
    else if days <= 7
      c.update posted_date.strftime("%a " + date_format_short)
    else if current_date.getFullYear() == posted_date.getFullYear()
      c.update posted_date.strftime(date_format_short)
    else
      c.update posted_date.strftime(date_format_long)


Object.extend Date.prototype,
  strftime: (format) ->
    day = @getDay()
    month = @getMonth()
    hours = @getHours()
    minutes = @getMinutes()
    pad = (num) ->
      num.toPaddedString(2)

    format.gsub /\%([aAbBcdDHiImMpSwyY])/, (((part) ->
      switch part[1]
        when 'a' then date_abbr_day_names[day]
        when 'A' then date_day_names[day]
        when 'b' then date_abbr_month_names[month]
        when 'B' then date_month_names[month]
        when 'c' then @toString()
        when 'd' then @getDate()
        when 'D' then pad @getDate()
        when 'H' then pad hours
        when 'i' then (if hours == 12 || hours == 0 then 12 else (hours + 12) % 12)
        when 'I' then (pad if hours == 12 || hours == 0 then 12 else (hours + 12) % 12)
        when 'm' then pad month + 1
        when 'M' then pad minutes
        when 'p' then (if hours > 11 then time_pm else time_am)
        when 'S' then pad @getSeconds()
        when 'w' then day
        when 'y' then pad @getFullYear() % 100
        when 'Y' then @getFullYear().toString()
    ).bind(this))