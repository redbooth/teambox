document.on('change', '.import_choices input[type=checkbox]', function(e, input) {
  if (input.hasClassName('can_create_users')) {
    input.up('form').down('.map_users').toggle();
  }
  else if (input.hasClassName('can_create_organizations')) {
    input.up('form').down('.target_project').toggle();
  }
});

document.on('change', '.new_teambox_data input.toggle[type=checkbox]', function(e, input) {
  input.up('form').select('.project input[type=checkbox]').each(function(input) {
    input.checked = !input.checked;
  })
});





