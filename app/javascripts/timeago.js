function format_posted_date()
{
  $$('span.timeago').each(function(c){
    current_date  = new Date();
    posted_date  = new Date();
    posted_date.setTime(c.readAttribute('alt'));
		
		posted_date_beginning_of_day = new Date(posted_date), current_date_beginning_of_day = new Date(current_date);
		
		posted_date_beginning_of_day.setHours(0);
		posted_date_beginning_of_day.setMinutes(0);
		posted_date_beginning_of_day.setSeconds(0);

		current_date_beginning_of_day.setHours(0);
		current_date_beginning_of_day.setMinutes(0);
		current_date_beginning_of_day.setSeconds(0);

		
    minutes = Math.floor((current_date-posted_date) / (1000 * 60));
    days = Math.floor((current_date_beginning_of_day-posted_date_beginning_of_day) / (1000 * 60 * 60 * 24));

		if (minutes < 0) {
			var time_error = true
		};

		if (typeof(time_error) != "undefined") { return }
    else if(minutes < 60)    { c.update(minutesAgoInWords(minutes)); }
    else if(days == 0)  { c.update(posted_date.strftime(time_format_short)); }
    else if(days == 1)  { c.update(date_yesterday + ' ' + posted_date.strftime(time_format_short)); }
    else if(days <= 7)       { c.update(posted_date.strftime("%a " + date_format_short)); }
    else if(current_date.getFullYear() == posted_date.getFullYear()) { c.update(posted_date.strftime(date_format_short)); }
    else c.update(posted_date.strftime(date_format_long));    
  }
  );
}



