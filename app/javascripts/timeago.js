function format_posted_date() {
  $$('time.timeago').each(function(c){
    var current_date = new Date(),
        posted_date = new Date(parseInt(c.readAttribute('data-msec'))),
		    posted_date_beginning_of_day = new Date(posted_date),
		    current_date_beginning_of_day = new Date(current_date)

    		posted_date_beginning_of_day.setHours(0)
    		posted_date_beginning_of_day.setMinutes(0)
    		posted_date_beginning_of_day.setSeconds(0)

    		current_date_beginning_of_day.setHours(0)
    		current_date_beginning_of_day.setMinutes(0)
    		current_date_beginning_of_day.setSeconds(0)

    var minutes = Math.round((current_date-posted_date) / (1000 * 60))
    var days = Math.round((current_date_beginning_of_day-posted_date_beginning_of_day) / (1000 * 60 * 60 * 24))
    var today = ((current_date.getDay() === posted_date.getDay() && days < 2) ? true : false)

		if (minutes < 0) return
    else if (minutes < 60) { c.update(minutesAgoInWords(minutes)) }
    else if (today)        { c.update(posted_date.strftime(time_format_short)) }
    else if (days == 1)    { c.update(date_yesterday + ' ' + posted_date.strftime(time_format_short)) }
    else if (days <= 7)    { c.update(posted_date.strftime("%a " + date_format_short)) }
    else if (current_date.getFullYear() == posted_date.getFullYear()) {
      c.update(posted_date.strftime(date_format_short))
    }
    else c.update(posted_date.strftime(date_format_long))
  })
}
