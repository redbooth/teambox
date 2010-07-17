if (Date.first_day_of_week == 1) {
    Date.weekdays = $w('Mo Di Mi Do Fr Sa So');
} else {
    Date.weekdays = $w('So Mo Di Mi Do Fr Sa');
}

Date.months = $w('Januar Februar März April Mai Juni Juli August September Oktober November Dezember');

_translations = {
  "OK": "OK",
  "Now": "Jetzt",
  "Today": "Heute",
  "Clear": "Löschen"
};
