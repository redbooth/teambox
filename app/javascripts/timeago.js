function format_posted_date() {
  $$('time.timeago').each(function(c){
    var current_date = new Date(),
        posted_date = new Date(parseInt(c.readAttribute('data-msec')))

    var minutes = Math.floor((current_date-posted_date) / (1000 * 60))
    var days = current_date.getDay() - posted_date.getDay()

		if (minutes < 0) return
    else if (minutes < 60) { c.update(minutesAgoInWords(minutes)) }
    else if (days == 0)    { c.update(posted_date.strftime(time_format_short)) }
    else if (days == 1)    { c.update(date_yesterday + ' ' + posted_date.strftime(time_format_short)) }
    else if (days <= 7)    { c.update(posted_date.strftime("%a " + date_format_short)) }
    else if (current_date.getFullYear() == posted_date.getFullYear()) {
      c.update(posted_date.strftime(date_format_short))
    }
    else c.update(posted_date.strftime(date_format_long))
  })
}
