document.on('click', 'div.date_picker', function(e, element) {
  var field = element.down('input')
  var label = element.down('span')
  var parentDiv = element.up('div')
  var date_picker = DatePicker.initialize(field, label, parentDiv);
  if (element.hasClassName("show_urgent")) {
    DatePicker.add_urgent_box(date_picker, element, field, label, parentDiv);    
  }
});

DatePicker = {
  initialize: function(field, label, parentDiv) {
    return(new CalendarDateSelect(field, {
      buttons: true,
      time: false,
      year_range: 10,
      embedded: false,
      close_on_click: true,
      popup_by: parentDiv,
      onchange: function() {
        selected_date = this.calendar_date_select.selected_date

        if ( /[\d]{4}-[\d]{1,2}-[\d]{1,2}\s[\d]{1,2}:[\d]{1,2}/.test(this.value) == true ) {
          localized_format = I18n.translations.time.formats.long
          localized_time = selected_date.strftime(localized_format)
        } else if ( /[\d]{4}-[\d]{1,2}-[\d]{1,2}/.test(this.value) == true ) {
          localized_format = I18n.translations.date.formats.long
          localized_time = selected_date.strftime(localized_format)
        } else {
          localized_time = this.value
        }
        label.update(localized_time || I18n.translations.date_picker.no_date_assigned);
      }
    }));
  },
  
  add_urgent_box: function(date_picker, element, field, label, parentDiv) {
    // Render custom urgent box on calendar's top DIV
    var urgent_field = field.parentNode.down("input.urgent");
    var html = Mustache.to_html(Templates.tasks.calendar_date_select_urgent_header, {
      task_id: element.id.split("_")[1]
    });
    date_picker.top_div.update(html);

    // Link toggler for help info
    date_picker.top_div.down(".show-help").observe("click", function(event) {
      date_picker.top_div.down(".help").toggle();
      event.stop();
    });
    
    // On urgent checkbox changes update task[urgent] and show/hide sections accordingly 
    var update_urgent_box = function (date_picker, input_urgent, user_action) { 
      urgent_field.value = input_urgent.checked ? "1" : "0";
      urgent_field.removeAttribute("disabled");
      
      if (input_urgent.checked) {
        label.update(I18n.translations.date_picker.urgent.short);
      } else if (user_action) { 
        date_picker.clearDate();
        date_picker.callback("onchange");
        label.update(I18n.translations.date_picker.no_date_assigned);
      }
      
      if (user_action && input_urgent.checked) {
        date_picker.close();
      } else {      
        date_picker.calendar_div.select("> div").each(function(div) { 
          if (!div.hasClassName("cds_top")) {
            div[input_urgent.checked ? "hide" : "show"]();
          } 
        });
      }
      date_picker.positionCalendarDiv();
    }
        
    var input_urgent = date_picker.top_div.down("input.urgent")
    input_urgent.checked = (urgent_field.value == "1");
    update_urgent_box(date_picker, input_urgent, false);
    input_urgent.observe("click", function() { 
      update_urgent_box(date_picker, this, true); 
    });
  } 
}
