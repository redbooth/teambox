Threads = {
  selectNext: function() {
    Threads.move('next')
  },
  selectPrevious: function() {
    Threads.move('previous')
  },
  move: function(direction) {
    if (!$$('.thread').any()) { return true }
    var sel = $$('.thread.selected').first()
    if (!sel) { sel = $$('.thread').first() }
    var next = sel[direction]('.thread')
    var btn = $('activity_paginate_link')
    if (sel && next) {
      $$('.thread.selected').invoke('removeClassName','selected')
      next.addClassName('selected')
      var offsetTop = next.viewportOffset().top
      if ( offsetTop < 0 || offsetTop + next.getHeight() > document.viewport.getHeight() )
      {
        Effect.ScrollTo(next, { duration: '0.4', offset: -40 })
      }
    }
    else if (!next && direction == 'next' && btn && btn.visible())
    {
      btn.fire('pseudo:click')
    }

  },
  toggleSelected: function() {
    ActivityFeed.toggle($$('.thread.selected').first())
  }
}

document.on('dom:loaded', function() {
  Hotkeys.key('j', function() { Threads.selectNext() })
  Hotkeys.key('k', function() { Threads.selectPrevious() })
  Hotkeys.key('enter', function() { Threads.toggleSelected() })
})

