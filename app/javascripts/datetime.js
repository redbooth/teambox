// Utility methods for relative time ago

Date.months = I18n.translations.date.month_names.compact();
Date.weekdays = I18n.translations.calendar.abbr_weekdays;
Date.first_day_of_week = "sunday";

document.on("dom:loaded", function() {
  if(!my_user) { return; }
  Date.first_day_of_week = my_user.first_day_of_week;
  if(Date.first_day_of_week == "monday") {
    Date.weekdays.push(Date.weekdays.shift());
  }
});

_translations = $w("OK Now Today Clear").collect(function(w) {
  return I18n.translations.calendar[w.toLowerCase()];
});

Object.extend(Date.prototype, {
  beginning_of_day: function() {
    var date = new Date(this);
    date.setHours(0);
    date.setMinutes(0);
    date.setSeconds(0);
    return date;
  },
  // Renders date with custom formatting, similar to Ruby's strftime
  strftime: function(format) {
    var minutes = this.getMinutes(),
        hours = this.getHours(),
        day = this.getDay(),
        month = this.getMonth(),
        t = I18n.translations;

    function pad(num) { return num.toPaddedString(2); } 

    return format.gsub(/\%([aAbBcdDHiImMpSwyY])/, function(part) {
      switch(part[1]) {
        case 'a': return t.date.abbr_day_names[day];
        case 'A': return t.date.day_names[day];
        case 'b': return t.date.abbr_month_names[month+1];
        case 'B': return t.date.month_names[month+1];
        case 'c': return this.strftime("%a %b %d %H:%M:%S %Y");
        case 'd': return this.getDate();
        case 'D': return pad(this.getDate());
        case 'H': return pad(hours);
        case 'i': return (hours === 12 || hours === 0) ? 12 : (hours + 12) % 12;
        case 'I': return pad((hours === 12 || hours === 0) ? 12 : (hours + 12) % 12);
        case 'm': return pad(month + 1);
        case 'M': return pad(minutes);
        case 'p': return hours > 11 ? t.time.pm : t.time.am;
        case 'S': return pad(this.getSeconds());
        case 'w': return day;
        case 'y': return pad(this.getFullYear() % 100);
        case 'Y': return this.getFullYear().toString();
      }
    }.bind(this));
  },
  // Will parse date and give its relative distance in words to
  // current_date (which defaults to now)
  timeAgo: function(current_date) {
    current_date = current_date || new Date();

    var posted_date = new Date(this);
    var elapsed = current_date - posted_date;

    var minutes = Math.floor(elapsed / (1000 * 60));
    var days = Math.floor(elapsed / (1000 * 60 * 60 * 24));
    var today = (current_date.getDay() === posted_date.getDay() && days < 2);
    var t = I18n.translations;

    if (elapsed < 0) {
      return posted_date.strftime(t.date.formats.long); }
    else if (minutes === 0) {
      return t.datetime.distance_in_words.now; }
    else if (minutes == 1) {
      return t.datetime.time_ago.gsub("%{time_ago_in_words}", t.datetime.distance_in_words.x_minutes.one); }
    else if (minutes < 60) {
      return t.datetime.time_ago.gsub("%{time_ago_in_words}", t.datetime.distance_in_words.x_minutes.other.gsub("%{count}", minutes)); }
    else if (today) {
      return posted_date.strftime(t.time.formats.short); }
    else if (days == 1) {
      return t.date.yesterday + ' ' + posted_date.strftime(t.time.formats.short); }
    else if (days <= 14) {
      return posted_date.strftime("%a " + t.date.formats.short); }
    else if (current_date.getFullYear() == posted_date.getFullYear()) {
      return posted_date.strftime(t.date.formats.short);
    }
    else { return posted_date.strftime(t.date.formats.long); }
  }
});

// Replaces all the cache-friendly static dates
// with relative time ago in words
Date.format_posted_dates = function() {
  $$('time.timeago').each(function(c){
    var date = new Date(parseInt(c.readAttribute('data-msec')));
    c.update(date.timeAgo());
  });
};

document.on("dom:loaded", function() {
  Date.format_posted_dates();
  new PeriodicalExecuter(Date.format_posted_dates, 30);
});

document.on("ajax:success", function() {
  Date.format_posted_dates.defer();
});

