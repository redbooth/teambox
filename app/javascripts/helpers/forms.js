(function () {
  var FormsHelper = {};

  /* Disable submit buttons
   *
   * @return self
   */
  FormsHelper.showDisabledInput = function(form) {
    var inputs = jQuery(form).find("input[type=submit][data-disable-with]");
    inputs.each(function(i,input) {
      jQuery(input)
        .val(jQuery(input).attr('data-disable-with'))
        .attr({
          'data-original-value': input.value,
          'disabled': 'disabled' });
    });
    return FormsHelper;
  };

  /* Restore disabled submit buttons
   * @return self
   */
  FormsHelper.restoreDisabledInputs = function(form) {
    var inputs = jQuery(form).find("input[type=submit][disabled=true][data-disable-with]");
    inputs.each(function(i,input) {
      jQuery(input)
        .val(jQuery(input).attr('data-original-value'))
        .attr({
          'data-original-value': null,
          'disabled': '' });
    });
    return FormsHelper;
  };


  // exporrts
  Teambox.helpers.forms = FormsHelper;

}());

