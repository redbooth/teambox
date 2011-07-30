// This plugin makes sure that there are no textareas with dirty content in the page
// before navigating away with Backbone. If there is a dirty textarea,
// we will ask for confirmation to navigate away

Backbone.History.prototype.super_checkUrl = Backbone.History.prototype.checkUrl;
Backbone.History.prototype.checkUrl = function() {

  // We're adding a filter before changing the URL
  var unsaved_changes =
    !this.skipUnsavedCheck &&
    $$("#content textarea").detect(
      function(textarea) {
        return (textarea.value || "").length > 0;
      });

  if (unsaved_changes) {
    if(!confirm("There are unsaved changes on this page.\n\nAre you sure you want to navigate away?")) {
      console.log("Aborting navigation");
      window.location.hash = this.fragment;
      // Since we are changing the hash, don't ask to confirm navigation next time
      this.skipUnsavedCheck = true;
      return;
    };
  }

  this.skipUnsavedCheck = false;

  // Perform checkUrl normally
  this.super_checkUrl();

};
