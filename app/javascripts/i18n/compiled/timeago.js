// render from /Users/charles/Documents/Rails/teambox/app/javascripts/i18n/timeago.erb// de

function do_timeAgoInWords_de(){
  $$('.timeago').each(
    function(c){
    c.update(
      timeAgoInWords_de(c.readAttribute('alt'))
      );
    }
  )
}


function timeAgoInWords_de(from) {
  seconds_ago = ((new Date().getTime()  - from) / 1000);
  minutes_ago = Math.floor(seconds_ago / 60);

  if(minutes_ago == 0) { return "weniger als 1 Minute"; }
  if(minutes_ago == 1) { return "1 Minute"; }
  if(minutes_ago < 60) { return ""+"" + minutes_ago + " Minuten"+""; }
  if(minutes_ago < 90) { return "circa 1 Stunde"; }
  hours_ago  = Math.floor(minutes_ago / 60);
  return " circa " + hours_ago + " Stunden ";
}
// es

function do_timeAgoInWords_es(){
  $$('.timeago').each(
    function(c){
    c.update(
      timeAgoInWords_es(c.readAttribute('alt'))
      );
    }
  )
}


function timeAgoInWords_es(from) {
  seconds_ago = ((new Date().getTime()  - from) / 1000);
  minutes_ago = Math.floor(seconds_ago / 60);

  if(minutes_ago == 0) { return "menos de 1 minuto"; }
  if(minutes_ago == 1) { return "1 minuto"; }
  if(minutes_ago < 60) { return ""+"" + minutes_ago + " minutos"+""; }
  if(minutes_ago < 90) { return "alrededor de 1 hora"; }
  hours_ago  = Math.floor(minutes_ago / 60);
  return " alrededor de " + hours_ago + " horas ";
}
// en

function do_timeAgoInWords_en(){
  $$('.timeago').each(
    function(c){
    c.update(
      timeAgoInWords_en(c.readAttribute('alt'))
      );
    }
  )
}


function timeAgoInWords_en(from) {
  seconds_ago = ((new Date().getTime()  - from) / 1000);
  minutes_ago = Math.floor(seconds_ago / 60);

  if(minutes_ago == 0) { return "less than a minute"; }
  if(minutes_ago == 1) { return "1 minute"; }
  if(minutes_ago < 60) { return ""+"" + minutes_ago + " minutes"+""; }
  if(minutes_ago < 90) { return "about 1 hour"; }
  hours_ago  = Math.floor(minutes_ago / 60);
  return " about " + hours_ago + " hours ";
}
// it

function do_timeAgoInWords_it(){
  $$('.timeago').each(
    function(c){
    c.update(
      timeAgoInWords_it(c.readAttribute('alt'))
      );
    }
  )
}


function timeAgoInWords_it(from) {
  seconds_ago = ((new Date().getTime()  - from) / 1000);
  minutes_ago = Math.floor(seconds_ago / 60);

  if(minutes_ago == 0) { return "meno di 1 minuto"; }
  if(minutes_ago == 1) { return "1 minuto"; }
  if(minutes_ago < 60) { return ""+"" + minutes_ago + " minuti"+""; }
  if(minutes_ago < 90) { return "circa 1 ora"; }
  hours_ago  = Math.floor(minutes_ago / 60);
  return " circa " + hours_ago + " ore ";
}
// fr

function do_timeAgoInWords_fr(){
  $$('.timeago').each(
    function(c){
    c.update(
      timeAgoInWords_fr(c.readAttribute('alt'))
      );
    }
  )
}


function timeAgoInWords_fr(from) {
  seconds_ago = ((new Date().getTime()  - from) / 1000);
  minutes_ago = Math.floor(seconds_ago / 60);

  if(minutes_ago == 0) { return "moins d'une minute"; }
  if(minutes_ago == 1) { return "1 minute"; }
  if(minutes_ago < 60) { return ""+"" + minutes_ago + " minutes"+""; }
  if(minutes_ago < 90) { return "environ 1 heure"; }
  hours_ago  = Math.floor(minutes_ago / 60);
  return " environ " + hours_ago + " heures ";
}
// ca

function do_timeAgoInWords_ca(){
  $$('.timeago').each(
    function(c){
    c.update(
      timeAgoInWords_ca(c.readAttribute('alt'))
      );
    }
  )
}


function timeAgoInWords_ca(from) {
  seconds_ago = ((new Date().getTime()  - from) / 1000);
  minutes_ago = Math.floor(seconds_ago / 60);

  if(minutes_ago == 0) { return "menys d'1 minut"; }
  if(minutes_ago == 1) { return "1 minut"; }
  if(minutes_ago < 60) { return ""+"" + minutes_ago + " minuts"+""; }
  if(minutes_ago < 90) { return "al voltant d'1 hora"; }
  hours_ago  = Math.floor(minutes_ago / 60);
  return " al voltant de " + hours_ago + " hores ";
}
