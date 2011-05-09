ActivityFeed = {
  collapseAll: function() {
    var activities = $('activities');
    if (activities) {
      $$('#activities .activity, #activities .thread').invoke("addClassName", "collapsed");
      activities.addClassName("collapsed");
      this.collapsed = true;
    }
  },
  expandAll: function() {
    var activities = $('activities');
    if (activities) {
      $$('#activities .activity, #activities .thread').invoke("removeClassName", "collapsed");
      activities.removeClassName("collapsed");
      this.collapsed = false;
    }
  },
  toggle: function(el) {
    el.toggleClassName("collapsed");
    Threads.select(el);
    Threads.ensureVisible(el);
  },
  collapsed: false
};

document.on("click", "a.collapsed_mode", function(e,el) {
  e.stop();
  ActivityFeed.collapseAll();
  $$('a.collapsed_mode')[0].up('.el').toggle();
  $$('a.expanded_mode')[0].up('.el').toggle();
  var r = new Ajax.Request('/account/activity_feed_mode/collapsed');
});

document.on("click", "a.expanded_mode", function(e,el) {
  e.stop();
  ActivityFeed.expandAll();
  $$('a.collapsed_mode')[0].up('.el').toggle();
  $$('a.expanded_mode')[0].up('.el').toggle();
  var r = new Ajax.Request('/account/activity_feed_mode/expanded');
});

document.on("click", "#activities .comment_header", function(e,el) {
  ActivityFeed.toggle(el.up('.thread'));
});

document.on("click", "#activities .comment_header a", function(e,el) {
  ActivityFeed.toggle(el.up('.thread'));
  if (e.isMiddleClick()) { return; }
  if (!el.up('.project_overlay')) {
    e.stop();
    window.location = el.readAttribute("href");
  }
});

document.on("dom:loaded", function() {
  if (my_user.collapse_activities && $$('a.collapsed_mode').any()) {
    ActivityFeed.collapseAll();
    $$('a.collapsed_mode').first().up('.el').toggle();
    $$('a.expanded_mode').first().up('.el').toggle();
  }
});

