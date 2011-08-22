Threads = {
  selectNext: function() {
    Threads.move('next');
  },
  selectPrevious: function() {
    Threads.move('previous');
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
    jQuery('.thread.selected').removeClass('selected');
    jQuery(element).addClass('selected');
  },
  ensureVisible: function(element) {
    console.log('Disabled ensureVisible');
    return;
    var offsetTop = element.viewportOffset().top
    if ( offsetTop < 0 || offsetTop + element.getHeight() > document.viewport.getHeight() )
    {
      Effect.ScrollTo(element, { duration: '0.4', offset: -40 })
    }
  },
  toggleSelected: function() {
    ActivityFeed.toggle(jQuery('.thread.selected'));
  }
}

jQuery(function() {

  jQuery(document)
    .bind('keydown', 'j', function() { Threads.selectNext(); })
    .bind('keydown', 'k', function() { Threads.selectPrevious(); })
    .bind('keydown', 'enter', function() { Threads.toggleSelected(); })

});
