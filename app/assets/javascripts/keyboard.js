Keyboard = {
  showHelp: function() {
    if (!jQuery('#keyboard_shortcuts').is(":visible")) {
      jQuery('#keyboard_shortcuts').fadeIn(400);
      setTimeout(function() { Keyboard.hideHelp(); }, 5000);
    }
  },
  hideHelp: function() {
    jQuery('#keyboard_shortcuts').fadeOut(400);
  }
};

jQuery(function() {
  var go = function(href) { return function() { document.location = href; } };
  jQuery(document)
    // Help menu
    .bind('keydown', 'h', Keyboard.showHelp)
    // Map search
    .bind('keydown', 'ctrl+s', function() { Teambox.views.search_view.focus(); })
    .bind('keydown', '/', function() { Teambox.views.search_view.focus(); })
    // Map navigation
    .bind('keydown', 'ctrl+q', go('#!/activities'))
    .bind('keydown', 'ctrl+w', go('#!/today'))
    .bind('keydown', 'ctrl+e', go('#!/my_tasks'))
    .bind('keydown', 'ctrl+r', go('#!/all_tasks'))
});
