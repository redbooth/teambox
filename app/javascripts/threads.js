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
      Threads.select(next)
      Threads.ensureVisible(next)
    }
    else if (!next && direction == 'next' && btn && btn.visible())
    {
      btn.fire('pseudo:click')
    }

  },
  select: function(element) {
    $$('.thread.selected').invoke('removeClassName','selected')
    element.addClassName('selected')
  },
  ensureVisible: function(element) {
      var offsetTop = element.viewportOffset().top
      if ( offsetTop < 0 || offsetTop + element.getHeight() > document.viewport.getHeight() )
      {
        Effect.ScrollTo(element, { duration: '0.4', offset: -40 })
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

