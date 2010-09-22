if (Date.first_day_of_week == 1) {
    Date.weekdays = $w("M T W T F S S");
} else {
    Date.weekdays = $w("S M T W T F S");
}

Date.months = $w('January February March April May June July August September October November December');

_translations = {
  "OK":"OK",
  "Now":"Now",
  "Today":"Today",
  "Clear":"Clear"
};