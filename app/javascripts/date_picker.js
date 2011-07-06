// TODO: Delete this
//document.on('click', 'div.date_picker', function (e, element) {
//  var field = element.down('input')
//    , label = element.down('span')
//    , parentDiv = element.up('div');
//
//  new Teambox.modules.CalendarDateSelect(field, {
//    buttons: true
//  , time: false
//  , year_range: 10
//  , embedded: false
//  , close_on_click: true
//  , popup_by: parentDiv
//  , onchange: function () {
//      var selected_date = this.calendar_date_select.selected_date
//        , localized_time, localized_format;
//
//      if (/[\d]{4}-[\d]{1,2}-[\d]{1,2}\s[\d]{1,2}:[\d]{1,2}/.test(this.value)) {
//        localized_format = I18n.translations.time.formats.long;
//        localized_time = selected_date.strftime(localized_format);
//      } else if (/[\d]{4}-[\d]{1,2}-[\d]{1,2}/.test(this.value)) {
//        localized_format = I18n.translations.date.formats.long;
//        localized_time = selected_date.strftime(localized_format);
//      } else {
//        localized_time = this.value;
//      }
//
//      label.update(localized_time);
//    }
//  });
//});
