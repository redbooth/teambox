if (Date.first_day_of_week == 1) {
    Date.weekdays = $w("Пн Вт Ср Чт Пт Сб Вс");
} else {
    Date.weekdays = $w("Вс Пн Вт Ср Чт Пт Сб");
}

Date.months = $w('Январь Февраль Март Апрель Май Июнь Июль Август Сентябрь Октябрь Ноябрь Декабрь');

_translations = {
  "OK": "OK",
  "Now": "Сейчас",
  "Today": "Сегодня",
  "Clear": "Ясно"  
};