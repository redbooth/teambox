if (Date.first_day_of_week == 1) {
    Date.weekdays = $w("D S T Q Q S S");
} else {
    Date.weekdays = $w("S D S T Q Q S");
}

Date.months = $w('Janeiro Fevereiro Março Abril Maio Junho Julho Agosto Setembro Outubro Novembro Dezembro');

_translations = {
  "OK": "OK",
  "Now": "Agora",
  "Today": "Hoje",
  "Clear": "Limpar"
};
