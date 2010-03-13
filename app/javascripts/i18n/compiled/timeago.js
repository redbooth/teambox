// render from /var/www/apps/teambox/app/javascripts/i18n/timeago.erb// ca

function format_posted_date_ca()
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

    if(minutes < 60)    { c.update(minutesAgoInWords_ca(minutes)); }
    else if(days == 0)  { c.update(posted_date.strftime_ca("%I:%M %p")); }
    else if(days == 1)  { c.update('Ahir ' + posted_date.strftime_ca("%I:%M %p")); }
    else if(days <= 7)       { c.update(posted_date.strftime_ca("%A %b %d")); }
    else if(current_date.getFullYear() == posted_date.getFullYear()) { c.update(posted_date.strftime_ca("%b %d")); }
    else c.update(posted_date.strftime_ca("%B %d, %Y"));    
  }
  );
}



function minutesAgoInWords_ca(minutes) {
  if(minutes == 0) { return "Hace menys d'1 minut"; }
  if(minutes == 1) { return "Hace 1 minut"; }
  return ""+"Hace " + minutes + " minuts"+"";
  }

// fr

function format_posted_date_fr()
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

    if(minutes < 60)    { c.update(minutesAgoInWords_fr(minutes)); }
    else if(days == 0)  { c.update(posted_date.strftime_fr("%I:%M %p")); }
    else if(days == 1)  { c.update('Hier ' + posted_date.strftime_fr("%I:%M %p")); }
    else if(days <= 7)       { c.update(posted_date.strftime_fr("%A %d %b")); }
    else if(current_date.getFullYear() == posted_date.getFullYear()) { c.update(posted_date.strftime_fr("%d %b")); }
    else c.update(posted_date.strftime_fr("%d %B %Y"));    
  }
  );
}



function minutesAgoInWords_fr(minutes) {
  if(minutes == 0) { return "Il y a moins d'une minute"; }
  if(minutes == 1) { return "Il y a 1 minute"; }
  return ""+"Il y a " + minutes + " minutes"+"";
  }

// es

function format_posted_date_es()
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

    if(minutes < 60)    { c.update(minutesAgoInWords_es(minutes)); }
    else if(days == 0)  { c.update(posted_date.strftime_es("%I:%M %p")); }
    else if(days == 1)  { c.update('Ayer ' + posted_date.strftime_es("%I:%M %p")); }
    else if(days <= 7)       { c.update(posted_date.strftime_es("%A %b %d")); }
    else if(current_date.getFullYear() == posted_date.getFullYear()) { c.update(posted_date.strftime_es("%b %d")); }
    else c.update(posted_date.strftime_es("%B %d, %Y"));    
  }
  );
}



function minutesAgoInWords_es(minutes) {
  if(minutes == 0) { return "Hace menos de 1 minuto"; }
  if(minutes == 1) { return "Hace 1 minuto"; }
  return ""+"Hace " + minutes + " minutos"+"";
  }

// de

function format_posted_date_de()
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

    if(minutes < 60)    { c.update(minutesAgoInWords_de(minutes)); }
    else if(days == 0)  { c.update(posted_date.strftime_de("%I:%M %p")); }
    else if(days == 1)  { c.update('Gestern ' + posted_date.strftime_de("%I:%M %p")); }
    else if(days <= 7)       { c.update(posted_date.strftime_de("%A %b %d")); }
    else if(current_date.getFullYear() == posted_date.getFullYear()) { c.update(posted_date.strftime_de("%b %d")); }
    else c.update(posted_date.strftime_de("%B %d, %Y"));    
  }
  );
}



function minutesAgoInWords_de(minutes) {
  if(minutes == 0) { return "weniger als 1 Minute vorher"; }
  if(minutes == 1) { return "1 Minute vorher"; }
  return ""+"" + minutes + " Minuten vorher"+"";
  }

// en

function format_posted_date_en()
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

    if(minutes < 60)    { c.update(minutesAgoInWords_en(minutes)); }
    else if(days == 0)  { c.update(posted_date.strftime_en("%I:%M %p")); }
    else if(days == 1)  { c.update('Yesterday ' + posted_date.strftime_en("%I:%M %p")); }
    else if(days <= 7)       { c.update(posted_date.strftime_en("%A %b %d")); }
    else if(current_date.getFullYear() == posted_date.getFullYear()) { c.update(posted_date.strftime_en("%b %d")); }
    else c.update(posted_date.strftime_en("%B %d, %Y"));    
  }
  );
}



function minutesAgoInWords_en(minutes) {
  if(minutes == 0) { return "less than a minute ago"; }
  if(minutes == 1) { return "1 minute ago"; }
  return ""+"" + minutes + " minutes ago"+"";
  }

// ru

function format_posted_date_ru()
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

    if(minutes < 60)    { c.update(minutesAgoInWords_ru(minutes)); }
    else if(days == 0)  { c.update(posted_date.strftime_ru("%H:%M")); }
    else if(days == 1)  { c.update('Вчера ' + posted_date.strftime_ru("%H:%M")); }
    else if(days <= 7)       { c.update(posted_date.strftime_ru("%A %d %b")); }
    else if(current_date.getFullYear() == posted_date.getFullYear()) { c.update(posted_date.strftime_ru("%d %b")); }
    else c.update(posted_date.strftime_ru("%d %b %Y"));    
  }
  );
}



function minutesAgoInWords_ru(minutes) {
  if(minutes == 0) { return "меньше минуты назад"; }
  if(minutes == 1) { return "минуту назад"; }
  return ""+"" + minutes + " минут назад"+"";
  }

// it

function format_posted_date_it()
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

    if(minutes < 60)    { c.update(minutesAgoInWords_it(minutes)); }
    else if(days == 0)  { c.update(posted_date.strftime_it("%I:%M %p")); }
    else if(days == 1)  { c.update('Ieri ' + posted_date.strftime_it("%I:%M %p")); }
    else if(days <= 7)       { c.update(posted_date.strftime_it("%A %b %d")); }
    else if(current_date.getFullYear() == posted_date.getFullYear()) { c.update(posted_date.strftime_it("%b %d")); }
    else c.update(posted_date.strftime_it("%B %d, %Y"));    
  }
  );
}



function minutesAgoInWords_it(minutes) {
  if(minutes == 0) { return "meno di 1 minuto fa"; }
  if(minutes == 1) { return "1 minuto fa"; }
  return ""+"" + minutes + " minuti fa"+"";
  }

