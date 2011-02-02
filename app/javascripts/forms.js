// Any form elements with class 'required' will be client-side validated 
// if the form itself also has the class 'required'
// Displays an inline span with the error message (taken from the element's error_message attribute)
//
document.on('ajax:before', 'form', function(e, form) {
  if (form.hasClassName('required')) {
    form.select('.required').each(function(input) {
        if (input.value.strip().empty()) {
          e.stop();
          input.previous('label').toggleClassName('error');
          var error = input.next('span.error');
          if (error) {
            error.remove();
          }
          input.insert({after: '<span class=error>(' + input.getAttribute('error_message') + ')</span>'})
          input.highlight({duration: 1, color: 'red'});
        }
      });
  }
});

// Closes the parent node when clicking a .closeThis link
document.on('click', 'a.closeThis', function(e, link) {
  e.preventDefault()
  $(link.parentNode).hide()
})

//Some forms get cached and thus their hidden auth token field's value is often
//stale. Ensure we use a fresh authenticity token value when submitting forms.
document.on('submit', 'form', function(e, form) {
  var metaTagAuthToken = $$('meta[name=csrf-token]')[0].getAttribute('content'),
      authTokenInput = form.down('input[name=authenticity_token]');

  if (metaTagAuthToken && !metaTagAuthToken.blank() && authTokenInput) {
    authTokenInput.value = metaTagAuthToken;
  }
});
