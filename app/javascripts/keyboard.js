Keyboard = {
  showHelp: function() {
    if (!$('keyboard_shortcuts').visible()) {
      Effect.Appear('keyboard_shortcuts', { duration: 0.4 });
      setTimeout(function() { Keyboard.hideHelp(); }, 5000);
    }
  },
  hideHelp: function() {
    Effect.Fade('keyboard_shortcuts', { duration: 0.4 });
  }
};

document.on('dom:loaded', function() {
  // Help menu
  Hotkeys.key('h', function() { Keyboard.showHelp(); });

  // Map search
  Hotkeys.key('s', function() { Teambox.views.search_view.focus(); });
  Hotkeys.key('/', function() { Teambox.views.search_view.focus(); });

  // Map navigation
  Hotkeys.key('q', '#!/');
  Hotkeys.key('w', '#!/today');
  Hotkeys.key('e', '#!/my_tasks');
  Hotkeys.key('r', '#!/all_tasks');
});
