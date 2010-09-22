if (Date.first_day_of_week == 1) {
    Date.weekdays = $w("Lu Ma Mi Ju Vi Sa Do");
} else {
    Date.weekdays = $w("Do Lu Ma Mi Ju Vi Sa");
}

Date.months = $w('Enero Febrero Marzo Abril Mayo Junio Julio Augusto Septiembre Octubre Noviembre Diciembre');

_translations = {
  "OK": "OK",
  "Now": "Ahora",
  "Today": "Hoy",
  "Clear": "Limpiar"
};
