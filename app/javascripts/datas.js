document.on('ajax:success', '.teambox_data a[data-method="delete"]', function(e, link) {
  link.up('.teambox_data').remove();
})

document.on('focusin', 'form.edit_teambox_data input.user', function(e, input) {
  var form = e.findElement('form')
  var people = (new Hash(_import_users_autocomplete)).values().flatten().uniq(),
    autocompleter = input.retrieve('autocompleter')

  if (autocompleter) {
    autocompleter.options.array = people
  } else {
    var container = new Element('div', { 'class': 'autocomplete' }).hide()
    input.insert({ after: container })
    autocompleter = new Autocompleter.Local(input, container, people, { tokens:[' '] })
    input.store('autocompleter', autocompleter)
  }
})