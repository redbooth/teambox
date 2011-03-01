Keyboard = {
  showHelp: function() {
    if (!$('keyboard_shortcuts').visible()) {
      Effect.Appear('keyboard_shortcuts', { duration: 0.4 })
      setTimeout(function() { Keyboard.hideHelp() }, 5000)
  }
  },
  hideHelp: function() {
    Effect.Fade('keyboard_shortcuts', { duration: 0.4 })
  }
}

document.on('dom:loaded', function() {
  Hotkeys.key('h', function() { Keyboard.showHelp()} )
})
