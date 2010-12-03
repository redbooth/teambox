
document.on('ajax:before', 'form', function(e, form) {
  form.select('.required').each(function(input) {
    if (input.value.strip().empty()) {
      e.stop();
      input.previous('label').toggleClassName('error');
      input.insert({after: '<span class=error>(' + input.getAttribute('error_message') + ')</span>'})
      input.highlight({duration: 1, color: 'red'});
    }
  });
});
