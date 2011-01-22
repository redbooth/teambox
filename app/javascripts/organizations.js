document.observe("dom:loaded", function() {
  var colour_settings = ['header_bar', 'links', 'link_hover', 'text', 'highlight']

  colour_settings.each(function(setting) {
    var fieldName = "organization_settings_colours_" + setting,
        swatchName = fieldName + '_swatch',
        field = $(fieldName)

    if (field && window.Control && window.Control.ColorPicker) {
			defaultColor = field.readAttribute('data-default-color')
      field.colorPicker = new Control.ColorPicker(fieldName, { IMAGE_BASE : "/images/colorPicker/", 'swatch': swatchName, 'defaultColor': defaultColor})
    }
  });
});
