// Utility methods for relative time ago
// Depend on translations

// Will parse date_given and give its relative distance in words to
// current_date (which defaults to now)
Date.timeAgo = function(date_given, current_date) {
  current_date = current_date || new Date();
  var posted_date = new Date(date_given),
      posted_date_beginning_of_day = new Date(posted_date),
      current_date_beginning_of_day = new Date(current_date);

  posted_date_beginning_of_day.setHours(0);
  posted_date_beginning_of_day.setMinutes(0);
  posted_date_beginning_of_day.setSeconds(0);

  current_date_beginning_of_day.setHours(0);
  current_date_beginning_of_day.setMinutes(0);
  current_date_beginning_of_day.setSeconds(0);

  var minutes = Math.floor((current_date-posted_date) / (1000 * 60));
  var days = Math.floor((current_date_beginning_of_day-posted_date_beginning_of_day) / (1000 * 60 * 60 * 24));
  var today = (current_date.getDay() === posted_date.getDay() && days < 2);

  if (minutes < 0) { return; }
  else if (minutes < 60) { return minutesAgoInWords(minutes); }
  else if (today)        { return posted_date.strftime(time_format_short); }
  else if (days == 1)    { return date_yesterday + ' ' + posted_date.strftime(time_format_short); }
  else if (days <= 7)    { return posted_date.strftime("%a " + date_format_short); }
  else if (current_date.getFullYear() == posted_date.getFullYear()) {
    return posted_date.strftime(date_format_short);
  }
  else { return posted_date.strftime(date_format_long); }
};

// Replaces all the cache-friendly static dates
// with relative time ago in words
Date.format_posted_dates = function() {
  $$('time.timeago').each(function(c){
    var relative_date = Date.timeAgo(parseInt(c.readAttribute('data-msec')));
    c.update(relative_date);
  });
};

document.on("dom:loaded", function() {
  Date.format_posted_dates();
  new PeriodicalExecuter(Date.format_posted_dates, 30);
});

document.on("ajax:success", function() {
  Date.format_posted_dates.defer();
});

