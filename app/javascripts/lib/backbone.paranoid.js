// This plugin makes sure that there are no textareas with dirty content in the page
// before navigating away with Backbone. If there is a dirty textarea,
// we will ask for confirmation to navigate away

// Idea: We could also make forms dirty when their elements are edited
// and unset the dirty attribute on ajax:success for the form

window.isPageDirty = function() {
  return $$("#content textarea").detect(function(textarea) {
    return (textarea.value || "").length > 0;
  });
}

window.onbeforeunload = function(e) {
  e = e || window.event;  
  // TODO: Actually, we should only count POST, PUT and DELETE AJAX
  // requests, and activeRequestCount is also counting the ones with GET
  // which do not generally represent "unsaved changes"
  if ((Ajax.activeRequestCount > 0) || window.isPageDirty()) {
    // For IE and Firefox
    if (e) { e.returnValue = "You have unsaved changes."; }
    // For Webkit
    return "You have unsaved changes.";
  }
};

// Patch Backbone to prevent navigating away a dirty form

Backbone.History.prototype.super_checkUrl = Backbone.History.prototype.checkUrl;
Backbone.History.prototype.checkUrl = function() {

  // We're adding a filter before changing the URL
  var unsaved_changes =
    !this.skipUnsavedCheck &&
    window.isPageDirty();

  if (unsaved_changes) {
    if(!confirm("There are unsaved changes on this page.\n\nAre you sure you want to navigate away?")) {
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
