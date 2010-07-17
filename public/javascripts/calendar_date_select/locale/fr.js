if (Date.first_day_of_week == 1) {
    Date.weekdays = $w("L Ma Me J V S D");
} else {
    Date.weekdays = $w("D L Ma Me J V S");
}

Date.months = $w('Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre');

_translations = {
  "OK": "OK",
  "Now": "Maintenant",
  "Today": "Aujourd'hui",
  "Clear": "Claire"  
};
