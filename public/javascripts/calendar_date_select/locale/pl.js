if (Date.first_day_of_week == 1) {
    Date.weekdays = $w("P W Ś C P S N");
} else {
    Date.weekdays = $w("N P W Ś C P S");
}

Date.months = $w('Styczeń Luty Marzec Kwiecień Maj Czerwiec Lipiec Sierpień Wrzesień Październik Listopad Grudzień');

_translations = {
  "OK": "OK",
  "Now": "Teraz",
  "Today": "Dziś",
  "Clear": "Jasny"  
};