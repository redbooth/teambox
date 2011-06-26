(function () {
  var FormsHelper = {};

  /* Disable submit buttons
   *
   * @return self
   */
  FormsHelper.showDisabledInput = function(form) {
    var inputs = form.select("input[type=submit][data-disable-with]");
    inputs.each(function(input) {
      input.disabled = true;
      input.writeAttribute('data-original-value', input.value);
      input.value = input.readAttribute('data-disable-with');
    });
    return FormsHelper;
  };

  /* Restore disabled submit buttons
   * @return self
   */
  FormsHelper.restoreDisabledInputs = function(form) {
    var inputs = form.select("input[type=submit][disabled=true][data-disable-with]");
    inputs.each(function(input) {
      input.value = input.readAttribute('data-original-value');
      input.writeAttribute('data-original-value', null);
      input.disabled = false;
    });
    return FormsHelper;
  };


  // exporrts
  Teambox.helpers.forms = FormsHelper;

}());

