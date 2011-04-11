// Hotkeys

Hotkeys = {

  cache: {},
  special: { enter: 45, "?": 191, "/": 223, "\\": 252, "`": 224 },

  // Hotkeys.keys({
  // 'a': function() { ... },
  // 'b': '/some/url'
  // })
  keys: function(options) {
    for(key in options) {
      Hotkeys.key(key, options[key]);
    }
  },

  // Hotkeys.key('e', function() { ... })
  // or
  // Hotkeys.key('i', '/some/url')
  key: function(key, value) {
    c = Hotkeys.special[key] == null ? key.charCodeAt(0) : Hotkeys.special[key];
    Hotkeys.cache[c] = value;
  }
};

document.on('dom:loaded', function() {
  $$('a[hotkey]').each(function (a) {
    Hotkeys.key(a.readAttribute('hotkey'), a.readAttribute('href'));
  });
});

// Captures all keystrokes and fires events for them
document.on('keyup', function(e) {

  // FIXME: Temporarily enabling shortcuts for all users
  //if (!my_user.keyboard_shortcuts) { return true; }

  // Ignore keystrokes on focused inputs (cause we're typing on it)
  if (e.target.match(":input")){ return true; }

  // Ignore combinations with key modifiers
  if (e.ctrlKey || e.altKey || e.metaKey) { return true; }

  var dest = Hotkeys.cache[e.keyCode + 32];
  // Call the function or redirect to the given URL
  if (dest) {
    Object.isFunction(dest) ? dest.call(this) : window.location = dest;
    e.stop();
  }

});

