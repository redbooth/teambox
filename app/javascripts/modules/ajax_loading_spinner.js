// Display a global spinner when there are active requests

Ajax.Responders.register({
  onCreate:   function() {
    $("global_loading").show(); },
  onComplete: function() {
    if (Ajax.activeRequestCount === 0) {
      $("global_loading").hide(); } }
});
