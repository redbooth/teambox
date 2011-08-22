// Display a global spinner when there are active requests

Ajax.Responders.register({
  onCreate:   function() {
    window.activeRequests = window.activeRequests || 0;
    window.activeRequests++;
    $("global_loading").show(); },
  onComplete: function() {
    window.activeRequests--;
    if (window.activeRequests < 1) {
      $("global_loading").hide(); } }
});

// Support for jQuery, until we remove the dependencies on it
jQuery(document).ajaxStart(function() {
  window.activeRequests = window.activeRequests || 0;
  // Prevent going below 0 (in case some requests are sent before this
  // code starts tracking them)
  window.activeRequests = Math.max(window.activeRequests + 1, 0);
  $("global_loading").show();
});

jQuery(document).ajaxComplete(function() {
  window.activeRequests = Math.max(window.activeRequests - 1, 0);
  if (window.activeRequests === 0) {
    $("global_loading").hide(); }
});
